-- Filmova databaze

-- Testovaci priklady

-- Testy integritních omezení
-----------------------------

-- Chyba - Přidává uživatele s neplatným emailem (Tento dotaz selže, protože email 'johndoeexample.com' neodpovídá omezení CHECK pro platný email.)
INSERT INTO Users (UserID, FirstName, LastName, Email, Password)
VALUES (1, 'John', 'Doe', 'johndoeexample.com', 'password123');

-- Chyba - Přidává film s příliš dlouhým titulem (Tento dotaz selže, protože délka titulu překračuje maximální povolenou délku 255 znaků.)
INSERT INTO Movies (MovieID, Title, ReleaseYear, DirectorID, AverageRating, MainActors, GenreID, Duration)
VALUES (1, 'This is a very long movie title that exceeds the maximum allowed length', 2022, 1, 8.5, 'Actor 1, Actor 2', 1, 120);

-- Chyba - Přidává hodnocení s neplatnou hodnotou (Tento dotaz selže, protože hodnota hodnocení 6.0 překračuje maximální povolenou hodnotu 5.0.)
INSERT INTO Ratings (RatingID, MovieID, UserID, Rating)
VALUES (1, 1, 1, 6.0);

-- Chyba - Přidává recenzi s prázdným datem (Tento dotaz selže, protože je vyžadováno, aby datum recenze bylo vyplněno (not null).)
INSERT INTO Reviews (ReviewID, UserID, MovieID, ReviewText, ReviewDate)
VALUES (1, 1, 1, 'This movie is great!', NULL);

-- Testování triggeru UpdateAverageRating
-----------------------------------------

SELECT AverageRating FROM Movies WHERE MovieID = 1;
--> AverageRating: 4.65

-- Vložení nového hodnocení
INSERT INTO Ratings (RatingID, MovieID, UserID, Rating)
VALUES (9, 1, 1, 4.0);

SELECT AverageRating FROM Movies WHERE MovieID = 1;
--> AverageRating: 4.43

-- Upravení existujícího hodnocení
UPDATE Ratings
SET Rating = 1
WHERE RatingID = 1;

SELECT AverageRating FROM Movies WHERE MovieID = 1;
--> AverageRating: 3.17

-- Odstranění existujícího hodnocení
DELETE FROM Ratings
WHERE RatingID = 1;

SELECT AverageRating FROM Movies WHERE MovieID = 1;
--> AverageRating: 4.25

-- Testování triggeru AddNewActors
----------------------------------

-- Přidání nového filmu do databáze s novými herci
INSERT INTO Movies (MovieID, Title, MainActors)
VALUES (6, 'Spider-Man: No Way Home', 'Tom Holland, Andrew Garfield, Tobey Maguire');

--> Přidání všechny MainActors do tabulky Actors jako jednotlivé záznamy herců 

-- Testování pohledů
--------------------

-- Získání informací o filmech a jejich režisérech:
SELECT * FROM MovieDirectors_VW;

-- Získání filmuů a jejich průmerného hodnocení
SELECT * FROM MovieRatings_VW;

-- Získání filmů a jejich žánrů
SELECT * FROM MovieGenres_VW;

-- Získání nejlépe hodnocených filmů pro každý žánr
SELECT * FROM TopRatedMoviesByGenre_VW;

-- Získání oblíbených filmů jednotlivých uživatelů
SELECT * FROM UserFavoriteMovies_VW;

-- Získání recenzí jednotlivých filmů
SELECT * FROM MovieReviews_VW;


-- Testování procedur
---------------------

-- Přidání nového hodnocení filmu
EXEC AddMovieRating @MovieID = 3, @UserID = 1, @Rating = 4.5;

-- Chyba - Uživatel nemůže mít více hodnocení u jednoho filmu
EXEC AddMovieRating @MovieID = 3, @UserID = 1, @Rating = 1;
--> 'User already has a rating for this movie.'

-- Přidání nové recenze filmu
EXEC AddMovieReview @MovieID = 3, @UserID = 1, @ReviewText = 'Awesome movie!', @ReviewDate = '2023-06-23';

-- Chyba - Uživatel nemůže míž více recenzí k jednomu filmu
EXEC AddMovieReview @MovieID = 3, @UserID = 1, @ReviewText = 'Again.. Awesome movie!', @ReviewDate = '2023-06-23';
-->  'User already has a review for this movie.'

-- Získání recenzí k filmu s daným ID:
EXEC GetMovieReviews @MovieID = 3;

-- Záskání filmů vydaných v roce 2010
EXEC SearchMoviesByReleaseYear @ReleaseYear = 2022;

-- Získání nejlépe hodnocených filmů podle žánru
EXEC GetTopMoviesByGenre @GenreID = 2;

-- Získání filmů s obsazením daného herce
EXEC SearchMoviesByActor @ActorFirstName = 'Tom', @ActorLastName = 'Holland';

-- Získání oblíbených filmů daného uživatele
-- Podle jména uživatele
EXEC GetUserFavoriteMovies @SearchTerm = 'John Doe';
-- Podle ID uživatele
EXEC GetUserFavoriteMovies @SearchTerm = 1;
-- Chyba - Uživatel neexistuje
EXEC GetUserFavoriteMovies @SearchTerm = "Tim Tomato";
--> 'User does not exist.'

-- Přidání oblíbeného filmu
EXEC AddFavoriteMovie @UserID = 1, @MovieID = 2;
--> Film s MovieID = 2 se přidá do tabulky oblíbených filmů 
EXEC AddFavoriteMovie @UserID = 1, @MovieID = 2;
--> Znovu se nepřidává, jelikož tento záznma již existuje

-- Odstranění oblíbeného filmu
EXEC RemoveFavoriteMovie @UserID = 1, @MovieID = 2;
--> Film s MovieID = 2 se odstraní z tabulky oblíbených filmů
EXEC RemoveFavoriteMovie @UserID = 1, @MovieID = 2;
--> 'The user does not have the movie marked as a favourite'



