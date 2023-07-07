-- Filmova databaze

-- Trigger pro aktualizovani prumerneho hodnoceni filmu 
CREATE OR ALTER TRIGGER UpdateAverageRating
ON Ratings
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Aktualizace průměrného hodnocení pouze pro ovlivněné filmy
    UPDATE Movies
    SET AverageRating = COALESCE(source.AverageRating, 0)
    FROM Movies
    JOIN (
        SELECT MovieID, AVG(Rating) AS AverageRating
        FROM Ratings
        WHERE MovieID IN (SELECT DISTINCT MovieID FROM inserted)
            OR MovieID IN (SELECT DISTINCT MovieID FROM deleted)
        GROUP BY MovieID
    ) AS source ON Movies.MovieID = source.MovieID;
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
  DECLARE @actor_id INT;
  DECLARE @first_name VARCHAR(MAX);
  DECLARE @last_name VARCHAR(MAX);
  
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
    
    -- Rozdělení jména herce na FirstName a LastName
    SET @first_name = LEFT(@actor_name, CHARINDEX(' ', @actor_name + ' ') - 1);
    SET @last_name = STUFF(@actor_name, 1, LEN(@first_name) + 1, '');
    
    -- Kontrola, zda herec již existuje v tabulce Actors
    IF NOT EXISTS (
      SELECT 1 FROM CastAndCrew WHERE PersonType = 'Actor' AND FirstName = @first_name AND LastName = @last_name
    )
    BEGIN
      -- Vygenerování nového ID pro herce
      SELECT @actor_id = SCOPE_IDENTITY();

      -- Vložení nového herce
      INSERT INTO CastAndCrew (PersonID, FirstName, LastName, PersonType)
      VALUES (@actor_id, @first_name, @last_name,'Actor');
    END;
  END;
END;
GO