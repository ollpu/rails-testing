class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
  end
  
  def edit
    @article = Article.find(params[:id])
  end
  
  def update
    if current_user && current_user.privileges >= User.priv_level_writer
      @article = Article.find(params[:id])
      @article.update article_params
      redirect_to @article
    else
      not_privileged
    end
  end
  
  def create
    if current_user && current_user.privileges >= User.priv_level_writer
      @article = Article.new(article_params)
      
      @article.save
      redirect_to @article
    else
      not_privileged
    end
  end
  
  @@max_articles = 8
  
  def index
    @articles = Article.order(created_at: :desc).limit(@@max_articles)
    @depth = @@max_articles
    # true if articles clipped off
    @cut = Article.count > @depth
  end
  
  def destroy
    if current_user && current_user.privileges >= User.priv_level_writer
      @article = Article.find(params[:id])
      @article.destroy
      redirect_to articles_path
    else
      not_privileged
    end
  end
  
  def more
    old_depth = params[:depth].to_i
    new_depth = old_depth + @@max_articles
    
    @articles = Article.order(created_at: :desc).offset(old_depth).limit(@@max_articles)
    @cut = Article.count > new_depth
    @load_more_path = articles_more_url(:depth => new_depth)
    
    respond_to do |format|
      format.html { render :partial => "more" }
    end
  end
  
  private
  def article_params
    params.require(:article).permit(:title, :text)
  end
  
  def not_privileged
    redirect_to root_url, :notice => "Sinulla ei ole oikeutta tehdä tätä."
  end
end
