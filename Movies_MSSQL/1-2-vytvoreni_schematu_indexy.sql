-- Filmova databaze

-- Indexy pro cizí klíče
------------------------
CREATE INDEX Directors_DirectorID_Index ON Directors(DirectorID);
CREATE INDEX Movies_DirectorID_Index ON Movies(DirectorID);
CREATE INDEX Movies_GenreID_Index ON Movies(GenreID);
CREATE INDEX Ratings_MovieID_Index ON Ratings(MovieID);
CREATE INDEX Ratings_UserID_Index ON Ratings(UserID);
CREATE INDEX FavoriteMovies_UserID_Index ON FavoriteMovies(UserID);
CREATE INDEX FavoriteMovies_MovieID_Index ON FavoriteMovies(MovieID);
CREATE INDEX Reviews_UserID_Index ON Reviews(UserID);
CREATE INDEX Reviews_MovieID_Index ON Reviews(MovieID);

-- Umožňuje rychlé vyhledávání hodnocení filmů na základě jejich ID a ID uživatele pro optimalizaci procedury AddMovieRating.
CREATE INDEX Ratings_MovieID_UserID_Index ON Ratings(MovieID, UserID);

-- Optimalizace GetMovieReviews. Urychluje vyhledávání recenzí na základě ID filmu a ID uživatele.
CREATE INDEX Reviews_MovieID_UserID_Index ON Reviews(MovieID, UserID);

-- Usnadňuje vyhledávání filmů na základě roku vydání, což je užitečné pro proceduru SearchMoviesByReleaseYear.
CREATE INDEX Movies_ReleaseYear_Index ON Movies(ReleaseYear);

-- Efektivní vyhledávání nejlepších filmů daného žánru podle průměrného hodnocení pro proceduru GetTopMoviesByGenre. Zrychlí seskupování filmů podle žánru a hodnocení.
CREATE INDEX Movies_GenreID_AverageRating_Index ON Movies(GenreID, AverageRating);

-- Urychluje vyhledávání filmů na základě hlavních herců, což je užitečné pro proceduru SearchMoviesByActor.
CREATE INDEX Movies_MainActors_Index ON Movies(MainActors);

-- Urychluje vyhledávání a odebrání filmu z oblíbených filmů daného uživatele pro procedury AddFavoriteMovie a RemoveFavoriteMovie. Zrychlení spojování uživatelů s jejich oblíbenými filmy.
CREATE INDEX FavoriteMovies_UserID_MovieID_Index ON FavoriteMovies(UserID, MovieID);
