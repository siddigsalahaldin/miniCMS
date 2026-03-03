class ReactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reactable
  before_action :set_reaction, only: [:destroy]

  # POST /posts/:post_id/reactions
  # POST /comments/:comment_id/reactions
  def create
    @reaction = @reactable.reactions.find_or_create_by(user: current_user) do |r|
      r.reaction_type = reaction_params[:reaction_type] || "like"
    end

    # Update reaction type if user already reacted (change their reaction)
    if @reaction.previously_new_record? == false
      @reaction.update(reaction_type: reaction_params[:reaction_type] || "like")
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @reactable, notice: "Reaction added." }
      format.json { render :show, status: :created, location: @reactable }
    end
  end

  # DELETE /reactions/1
  def destroy
    @reaction.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @reactable, notice: "Reaction removed." }
      format.json { head :no_content }
    end
  end

  # POST /posts/:post_id/reactions/toggle
  def toggle
    @reaction = @reactable.reactions.find_by(user: current_user)

    if @reaction
      @reaction.destroy
      reacted = false
    else
      @reaction = @reactable.reactions.create!(
        user: current_user,
        reaction_type: reaction_params[:reaction_type] || "like"
      )
      reacted = true
    end

    respond_to do |format|
      format.turbo_stream
      format.html do
        notice = reacted ? "Reaction added." : "Reaction removed."
        redirect_to @reactable, notice: notice
      end
      format.json { render :show, status: :ok }
    end
  end

  # GET /posts/:post_id/reactions
  def index
    @reactions = @reactable.reactions
                           .with_user
                           .recent
                           .limit(50)
  end

  private

  def set_reactable
    if params[:post_id]
      @reactable = Post.friendly.find(params[:post_id])
    elsif params[:comment_id]
      @reactable = Comment.find(params[:comment_id])
    end
  end

  def set_reaction
    @reaction = Reaction.find(params[:id])
  end

  def reaction_params
    params.require(:reaction).permit(:reaction_type)
  end
end
