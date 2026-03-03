# Advanced search functionality for PostgreSQL/SQLite
module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search, ->(query) {
      return all if query.blank?
      
      # PostgreSQL full-text search (if available)
      begin
        where("search_vector @@ plainto_tsquery('english', ?)", query)
          .rank_by_search(query)
      rescue ActiveRecord::StatementInvalid
        # Fallback to basic search
        search_basic(query)
      end
    }
    
    scope :search_basic, ->(query) {
      return all if query.blank?
      
      # Search in title (body is in rich_text, handled separately)
      search_terms = query.split
      conditions = search_terms.map { |term| 
        "title LIKE ?" 
      }.join(' AND ')
      values = search_terms.flat_map { |term| ["%#{term}%"] }
      where(conditions, *values)
    }
    
    scope :rank_by_search, ->(query) {
      return all if query.blank?
      
      # Order by relevance (PostgreSQL)
      begin
        select("#{table_name}.*", "ts_rank(search_vector, plainto_tsquery('english', '#{sanitize_sql(query)}')) AS search_rank")
          .order("search_rank DESC")
      rescue ActiveRecord::StatementInvalid
        # Fallback for SQLite or if tsvector not set up
        order(created_at: :desc)
      end
    }
  end

  class_methods do
    # Search across multiple fields
    def global_search(query)
      return none if query.blank?
      
      # Search in posts
      posts_result = if respond_to?(:search)
        search(query)
      else
        search_basic(query)
      end
      
      {
        posts: posts_result.limit(10),
        query: query,
        total_results: posts_result.count
      }
    end

    # Highlight search terms in text
    def highlight_text(text, query)
      return text if query.blank? || text.blank?
      
      terms = query.split.uniq
      result = text.to_s
      terms.each do |term|
        result = result.gsub(/(#{Regexp.escape(term)})/i, '<mark class="search-highlight">\1</mark>')
      end
      result
    end
  end

  # Update search vector before save (PostgreSQL)
  def update_search_vector
    return unless respond_to?(:search_vector) && defined?(PG)
    
    # Combine title and body for full-text search
    self.search_vector = <<-SQL.squish
      setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
      setweight(to_tsvector('english', coalesce(body, '')), 'B')
    SQL
  end
end
