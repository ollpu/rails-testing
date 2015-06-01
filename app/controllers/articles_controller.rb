class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
  end
  
  def edit
    @article = Article.find(params[:id])
  end
  
  def update
    if current_user && current_user.privileges >= current_user.priv_level_writer
      @article = Article.find(params[:id])
      @article.update article_params
      redirect_to @article
    else
      not_privileged
    end
  end
  
  def create
    if current_user && current_user.privileges >= current_user.priv_level_writer
      @article = Article.new(article_params)
      
      @article.save
      redirect_to @article
    else
      not_privileged
    end
  end
  
  def index
    #= Needs some ajax magic
    # max_articles = 8
    # @articles = Article.order(created_at: :desc).limit(max_articles)
    # # true if articles clipped off
    # @cut = Article.count > max_articles
    #=
    @articles = Article.order(created_at: :desc)
  end
  
  def destroy
    if current_user && current_user.privileges >= current_user.priv_level_writer
      @article = Article.find(params[:id])
      @article.destroy
      redirect_to articles_path
    else
      not_privileged
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
