-- Filmova databaze

-- Vypis o filmech a jejich reziserech
CREATE VIEW MovieDirectors_VW AS
SELECT m.MovieID, m.Title, m.ReleaseYear, d.FirstName, d.LastName
FROM Movies m
JOIN Directors d ON m.DirectorID = d.DirectorID;
GO;

-- Vypis filmu s jejich prumernym hodnocenim
CREATE VIEW MovieRatings_VW AS
SELECT m.MovieID, m.Title, m.AverageRating
FROM Movies m;
GO;

-- Vypis nejlepe hodnoceneho film pro kazdy zanr (stejne hodnoceni - Vypisi se vsechny nejlepsi)
CREATE VIEW TopRatedMoviesByGenre_VW AS
WITH top_movies AS (
  SELECT m.MovieID, m.Title, g.Name AS Genre, m.AverageRating,
         ROW_NUMBER() OVER (PARTITION BY g.GenreID ORDER BY m.AverageRating DESC) AS rn
  FROM Movies m
  JOIN Genres g ON m.GenreID = g.GenreID
)
SELECT MovieID, Title, Genre
FROM top_movies tm
WHERE EXISTS (
  SELECT 1
  FROM top_movies tm2
  WHERE tm.Genre = tm2.Genre
  GROUP BY tm2.Genre
  HAVING MAX(tm2.AverageRating) = tm.AverageRating
);
GO;

-- Vypis filmu s jejich informacemi a zanry
CREATE VIEW MovieGenres_VW AS
SELECT m.MovieID, m.Title, g.Name AS Genre
FROM Movies m
JOIN Genres g ON m.GenreID = g.GenreID;
GO;

-- Vypis oblibenych filmu jednotlivych uzivatelu
CREATE VIEW UserFavoriteMovies_VW AS
SELECT u.UserID, u.FirstName, u.LastName, m.MovieID, m.Title
FROM Users u
JOIN FavoriteMovies f ON u.UserID = f.UserID
JOIN Movies m ON f.MovieID = m.MovieID;
GO;

-- Vypis recenzi jednotlivych filmu
CREATE VIEW MovieReviews_VW AS
SELECT m.MovieID, m.Title, r.UserID, r.ReviewText, r.ReviewDate
FROM Movies m
JOIN Reviews r ON m.MovieID = r.MovieID;
GO;