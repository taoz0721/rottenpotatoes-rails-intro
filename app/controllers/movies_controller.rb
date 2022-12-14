class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @rating_to_show = Movie.all_ratings

    
    session[:ratings] = params[:ratings] unless params[:ratings].nil?
    session[:sort] = params[:sort] unless params[:sort].nil?

    if(params[:sort].nil? && !(session[:sort].nil?) || params[:ratings].nil? && !(session[:ratings].nil?))
      redirect_to movies_path(sort: session[:sort], ratings: session[:ratings])
    end

    # empty/nil condition
    if params[:ratings].nil? || params[:ratings].empty?
      @ratings_to_show = Movie.all_ratings
    elsif params[:ratings].empty?
      @ratings_to_show = []
    else
      @ratings_to_show = params[:ratings].keys
      params[:ratings] = Hash[@ratings_to_show.collect { |item| [item, '1'] } ]
    end
   
    session[:ratings] = params[:ratings] 
    @movies = Movie.with_ratings(@ratings_to_show)
    
    if params[:sort] == "title"
      @titleCSS = "hilite"
      @release_dateCSS = ""
      @movies = Movie.with_ratings(@ratings_to_show).order("title")
      session[:sort] = "title"
    elsif params[:sort] == "release"
      @titleCSS = ""
      @release_dateCSS = "hilite"
      @movies = Movie.with_ratings(@ratings_to_show).order("release_date")
      session[:sort] = "release"
    else
      @movies = Movie.with_ratings(@ratings_to_show) #unsorted
      session[:sort] = nil
    end
 

  end

  def new
    # default: render 'new' template

  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
