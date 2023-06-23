-- Filmova databaze

-- Views
DROP VIEW MovieDirectors_VW;
DROP VIEW MovieRatings_VW;
DROP VIEW TopRatedMoviesByGenre_VW;
DROP VIEW MovieGenres_VW;
DROP VIEW UserFavoriteMovies_VW;
DROP VIEW MovieReviews_VW;

-- Procedures
DROP PROCEDURE AddMovieRating;
DROP PROCEDURE AddMovieReview;
DROP PROCEDURE GetMovieReviews;
DROP PROCEDURE SearchMoviesByReleaseYear;
DROP PROCEDURE GetTopMoviesByGenre;
DROP PROCEDURE SearchMoviesByActor;
DROP PROCEDURE GetUserFavoriteMovie;
DROP PROCEDURE AddFavoriteMovie;
DROP PROCEDURE RemoveFavoriteMovie;

-- Tables
DROP TABLE Reviews;
DROP TABLE FavoriteMovies;
DROP TABLE Ratings;
DROP TABLE Genres;
DROP TABLE Actors;
DROP TABLE Directors;
DROP TABLE Movies;
DROP TABLE Users;
