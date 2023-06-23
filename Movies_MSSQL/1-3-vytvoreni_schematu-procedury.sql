-- Filmova databaze

-- Procedura pro vytvoreni hodnoceni filmu
CREATE PROCEDURE AddMovieRating
    @MovieID INT,
    @UserID INT,
    @Rating DECIMAL(2,1)
AS
BEGIN
    -- Uživatel může mít pouze jedno hodnocení k filmu
    IF NOT EXISTS (
        SELECT 1
        FROM Ratings
        WHERE MovieID = @MovieID AND UserID = @UserID
    )
    BEGIN
        DECLARE @RatingID INT;

        -- Vytvoření nového RatingID 
        SELECT @RatingID = ISNULL(MAX(RatingID), 0) + 1
        FROM Ratings;

        INSERT INTO Ratings (RatingID, MovieID, UserID, Rating)
        VALUES (@RatingID, @MovieID, @UserID, @Rating);
    END;
    ELSE
    BEGIN
        RAISERROR('User already has a rating for this movie.', 16, 1);
    END;
END;
-- Volani procedury:
    -- EXEC AddMovieRating @MovieID = 3, @UserID = 1, @Rating = 4.5;
GO;

-- Procedura pro přidání recenze k filmu
CREATE PROCEDURE AddMovieReview
    @MovieID INT,
    @UserID INT,
    @ReviewText TEXT,
    @ReviewDate DATE
AS
BEGIN
    -- Uživatel může mít pouze jednu recenzi k filmu
    IF NOT EXISTS (
        SELECT 1
        FROM Reviews 
        WHERE MovieID = @MovieID AND UserID = @UserID
    )
    BEGIN
        DECLARE @ReviewID INT;

        -- Vytvoření nového ReviewID
        SELECT @ReviewID = ISNULL(MAX(ReviewID), 0) + 1
        FROM Reviews;

        INSERT INTO Reviews (ReviewID, MovieID, UserID, ReviewText, ReviewDate)
        VALUES (@ReviewID, @MovieID, @UserID, @ReviewText, @ReviewDate);
    END;
    ELSE
    BEGIN
        RAISERROR('User already has a review for this movie.', 16, 1);
    END;
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

-- Procedrua pro zobrazeni oblibenych filmu daneho uzivatele - Vyhledani podle ID nebo jména uživatele
CREATE PROCEDURE GetUserFavoriteMovies
    @SearchTerm NVARCHAR(60)
AS
BEGIN
    DECLARE @UserID INT;

    -- Pokud je poskytnuto celé jméno, vyhledejte ID uživatele
    IF ISNUMERIC(@SearchTerm) = 0
    BEGIN
        SELECT @UserID = UserID
        FROM Users
        WHERE CONCAT(FirstName, ' ', LastName) = @SearchTerm;
    END
    ELSE
    BEGIN
        SET @UserID = CAST(@SearchTerm AS INT);
    END

    -- Pokud není nalezen žádný uživatel, vrať chybovou zprávu
    IF @UserID IS NULL
    BEGIN
        RAISERROR('User does not exist.', 16, 1);
        RETURN;
    END

    -- Získejte oblíbené filmy uživatele
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
    -- EXEC GetUserFavoriteMovies @SearchTerm = 'John Doe';
GO;

-- Procedura pro přidání filmu do oblíbených filmů uživatele, každý oblíbený film uživatele je zaznamenaný pouze jednou
CREATE PROCEDURE AddFavoriteMovie
    @UserID INT,
    @MovieID INT
AS
BEGIN
    -- Zkontrolujte, zda uživatel již nemá film uložený jako oblíbený
    IF EXISTS (
        SELECT 1
        FROM FavoriteMovies
        WHERE UserID = @UserID AND MovieID = @MovieID
    )
    BEGIN
        -- Film již je uložený jako oblíbený
        RETURN;
    END

    -- Přidejte film jako oblíbený
    INSERT INTO FavoriteMovies (UserID, MovieID)
    VALUES (@UserID, @MovieID);
END;
-- Volání procedury:
    -- EXEC AddFavoriteMovie @UserID = 1, @MovieID = 1;
GO;

-- Procedura pro odstranění filmu z oblíbených filmů uživatele, pokud film není v oblíbených, informujeme o tom uživatele
CREATE PROCEDURE RemoveFavoriteMovie
    @UserID INT,
    @MovieID INT
AS
BEGIN
    -- Kontrola, zda se film nachází mezi oblíbenými
    IF EXISTS (
        SELECT 1
        FROM FavoriteMovies
        WHERE UserID = @UserID AND MovieID = @MovieID
    )
    BEGIN
        -- Odstranění filmu z oblíbených
        DELETE FROM FavoriteMovies
        WHERE UserID = @UserID AND MovieID = @MovieID;
    END
    ELSE
    BEGIN
        -- Film se nenachází mezi oblíbenými, vyvolání chyby
        RAISERROR('The user does not have the movie marked as a favourite', 16, 1);
    END
END;
-- Volání procedury:
    -- EXEC RemoveFavoriteMovie @UserID = 1, @MovieID = 1;
GO;