CREATE TABLE Users (
  UserID int PRIMARY KEY,
  FirstName nvarchar(30) NOT NULL,
  LastName nvarchar(30) NOT NULL,
  Email nvarchar(60) NOT NULL UNIQUE
    check (Email like '%_@_%.__%'),
  Password nvarchar(60)
);

CREATE TABLE Movies (
  MovieID int PRIMARY KEY,
  Title nvarchar(255) NOT NULL UNIQUE,
  ReleaseYear int,
  DirectorID int,
  AverageRating DECIMAL(4,2),
  MainActors nvarchar(255),
  GenreID int,
  Duration int
    check (Duration > 0)
);

CREATE TABLE Directors (
  DirectorID int PRIMARY KEY,
  FirstName nvarchar(60) NOT NULL,
  LastName nvarchar(60) NOT NULL,
  DateOfBirth DATE,
  CountryOfOrigin varchar(60),
  constraint U_Director_FirstName_LastName UNIQUE (FirstName, LastName)
);

CREATE TABLE Actors (
  ActorID int PRIMARY KEY,
  FirstName nvarchar(60) NOT NULL,
  LastName nvarchar(60) NOT NULL,
  DateOfBirth DATE,
  CountryOfOrigin varchar(60),
  constraint U_Actor_FirstName_LastName UNIQUE (FirstName, LastName)
);

CREATE TABLE Genres (
  GenreID int PRIMARY KEY,
  Name varchar(30) NOT NULL
);

CREATE TABLE Ratings (
  RatingID int PRIMARY KEY,
  MovieID int NOT NULL,
  UserID int NOT NULL,
  Rating decimal(2,1) NOT NULL
    check (Rating >= 0 AND Rating <= 5),  
  FOREIGN KEY (MovieID) REFERENCES Movies (MovieID) ON DELETE CASCADE,
  FOREIGN KEY (UserID) REFERENCES Users (UserID)
);

CREATE TABLE FavoriteMovies (
  FavoriteID int PRIMARY KEY,
  UserID int NOT NULL,
  MovieID int NOT NULL,
  FOREIGN KEY (UserID) REFERENCES Users (UserID) ON DELETE CASCADE,
  FOREIGN KEY (MovieID) REFERENCES Movies (MovieID) ON DELETE CASCADE,
  constraint U_UserID_MovieID_Favorite UNIQUE (UserID, MovieID)
);

CREATE TABLE Reviews (
  ReviewID int PRIMARY KEY,
  UserID int,
  MovieID int,
  ReviewText TEXT NOT NULL,
  ReviewDate DATE,
  constraint FK_UserID FOREIGN KEY (UserID) REFERENCES Users (UserID) ON DELETE CASCADE,
  constraint FK_MovieID FOREIGN KEY (MovieID) REFERENCES Movies (MovieID) ON DELETE CASCADE,
  constraint NN_Reviews_UserID check (UserID IS NOT NULL),
  constraint NN_Reviews_MovieID check (MovieID IS NOT NULL),
  constraint NN_Reviews_ReviewDate check (ReviewDate IS NOT NULL),
  constraint U_UserID_MovieID_Review UNIQUE (UserID, MovieID)
);
GO;

-- Trigger pro aktualizovani prumerneho hodnoceni filmu
CREATE OR ALTER TRIGGER UpdateAverageRating
ON Ratings
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @totalRating DECIMAL(10,2);
    DECLARE @ratingCount INT;
    DECLARE @averageRating DECIMAL(4,2);

    -- Získání celkového hodnocení a počtu hodnocení pro daný film
    SELECT @totalRating = COALESCE(SUM(Rating), 0), @ratingCount = COALESCE(COUNT(*), 0)
    FROM Ratings
    WHERE MovieID = (SELECT MovieID FROM inserted);

    -- Výpočet průměrného hodnocení
    IF @ratingCount > 0
    BEGIN
        SET @averageRating = @totalRating / @ratingCount;
    END
    ELSE
    BEGIN
        SET @averageRating = 0;
    END

    -- Aktualizace průměrného hodnocení ve filmu
    UPDATE Movies
    SET AverageRating = @averageRating
    WHERE MovieID = (SELECT MovieID FROM inserted);
END;
GO

-- Trigger pro vkládání nových herců při vložení filmu
CREATE OR ALTER TRIGGER AddNewActors
ON Movies
AFTER INSERT
AS
BEGIN
  DECLARE @actor_names VARCHAR(MAX);
  DECLARE @actor_name VARCHAR(MAX);
  
  -- Získání seznamu herců z vkládaného filmu
  SELECT @actor_names = MainActors
  FROM inserted;
  
  -- Rozdělení herců na základě čárky a iterace přes ně
  WHILE LEN(@actor_names) > 0
  BEGIN
    -- Získání prvního herce
    SET @actor_name = LEFT(@actor_names, CHARINDEX(',', @actor_names + ',') - 1);
    
    -- Odstranění prvního herce ze seznamu
    SET @actor_names = STUFF(@actor_names, 1, LEN(@actor_name) + 1, '');
    
    -- Odstranění mezer z jména herce
    SET @actor_name = LTRIM(RTRIM(@actor_name));
    
    -- Kontrola, zda herec již existuje v tabulce Actors
    IF NOT EXISTS (
      SELECT 1 FROM Actors WHERE CONCAT(FirstName, ' ', LastName) = @actor_name
    )
    BEGIN
      -- Vložení nového herce
      INSERT INTO Actors (FirstName, LastName)
      VALUES (@actor_name, '');
    END;
  END;
END;
GO

-- Filomova databaze

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

GO;

-- Filmova databaze

-- Procedura pro vytvoreni hodnoceni filmu
CREATE PROCEDURE AddMovieRating
    @MovieID INT,
    @UserID INT,
    @Rating DECIMAL(2,1)
AS
BEGIN
    INSERT INTO Ratings (MovieID, UserID, Rating)
    VALUES (@MovieID, @UserID, @Rating);
END;
-- Volani procedury:
    -- EXEC AddMovieRating @MovieID = 1, @UserID = 1, @Rating = 4.5;
GO;

-- Procedura pro přidání recenze k filmu
CREATE PROCEDURE AddMovieReview
    @MovieID INT,
    @UserID INT,
    @ReviewText TEXT,
    @ReviewDate DATE
AS
BEGIN
    INSERT INTO Reviews (MovieID, UserID, ReviewText, ReviewDate)
    VALUES (@MovieID, @UserID, @ReviewText, @ReviewDate);
END;
-- Volání procedury:
    -- EXEC AddMovieReview @MovieID = 1, @UserID = 1, @ReviewText = 'The best movie I have ever seen.', @ReviewDate = '2023-06-21';
GO;

-- Procedura pro získání všech recenzí k danému filmu
CREATE PROCEDURE GetMovieReviews
    @MovieID INT
AS
BEGIN
    SELECT
        r.ReviewID,
        r.UserID,
        u.FirstName,
        u.LastName,
        r.ReviewText,
        r.ReviewDate
    FROM
        Reviews r
    INNER JOIN
        Users u ON r.UserID = u.UserID
    WHERE
        r.MovieID = @MovieID;
END;
-- Volání procedury:
    -- EXEC GetMovieReviews @MovieID = 1;
GO;

-- Procedura pro vyhledání filmů v daném roce vydání
CREATE PROCEDURE SearchMoviesByReleaseYear
    @ReleaseYear INT
AS
BEGIN
    SELECT
        MovieID,
        Title,
        AverageRating
    FROM
        Movies
    WHERE
        ReleaseYear = @ReleaseYear;
END;
-- Volání procedury:
    -- EXEC SearchMoviesByReleaseYear @ReleaseYear = 2022;
GO;

-- Procedura pro ziskani nejlepsich filmu daneho zanru 
CREATE PROCEDURE GetTopMoviesByGenre
    @GenreID INT
AS
BEGIN
    SELECT TOP 10
        m.MovieID,
        m.Title,
        m.AverageRating
    FROM
        Movies m
    WHERE
        m.GenreID = @GenreID
    ORDER BY
        m.AverageRating DESC;
END;
-- Volani procedury:
    -- EXEC GetTopMoviesByGenre @GenreID = 1;
GO;

-- Procedura pro vyhledavani filmu s danym hercem
CREATE PROCEDURE SearchMoviesByActor
    @ActorFirstName NVARCHAR(60),
    @ActorLastName NVARCHAR(60)
AS
BEGIN
    SELECT
        m.MovieID,
        m.Title,
        m.AverageRating
    FROM
        Movies m
    WHERE
        m.MainActors LIKE '%' + @ActorFirstName + ' ' + @ActorLastName + '%';
END;
-- Volani procedury:
    -- EXEC SearchMoviesByActor @ActorFirstName = 'Tom', @ActorLastName = 'Hanks';
GO;

-- Procedrua pro zobrazeni oblibenych filmu daneho uzivatele
CREATE PROCEDURE GetUserFavoriteMovies
    @UserID INT
AS
BEGIN
    SELECT
        m.MovieID,
        m.Title,
        m.AverageRating
    FROM
        Movies m
    INNER JOIN
        FavoriteMovies fm ON m.MovieID = fm.MovieID
    WHERE
        fm.UserID = @UserID;
END;
-- Volani procedury:
    -- EXEC GetUserFavoriteMovies @UserID = 1;
GO;

-- Procedura pro přidání filmu do oblíbených filmů uživatele
CREATE PROCEDURE AddFavoriteMovie
    @UserID INT,
    @MovieID INT
AS
BEGIN
    INSERT INTO FavoriteMovies (UserID, MovieID)
    VALUES (@UserID, @MovieID);
END;
-- Volání procedury:
    -- EXEC AddFavoriteMovie @UserID = 1, @MovieID = 1;
GO;

-- Procedura pro odstranění filmu z oblíbených filmů uživatele
CREATE PROCEDURE RemoveFavoriteMovie
    @UserID INT,
    @MovieID INT
AS
BEGIN
    DELETE FROM FavoriteMovies
    WHERE UserID = @UserID AND MovieID = @MovieID;
END;
-- Volání procedury:
    -- EXEC RemoveFavoriteMovie @UserID = 1, @MovieID = 1;

GO;

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

