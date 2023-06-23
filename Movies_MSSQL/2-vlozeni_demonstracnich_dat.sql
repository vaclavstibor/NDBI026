-- Filmova databaze

-- Vlozeni dat do tabulky Movies

INSERT INTO Movies 
  (MovieID, Title, ReleaseYear, DirectorID, AverageRating, MainActors, GenreID, Duration)
  VALUES
    (1, 'The Shawshank Redemption', 1994, 1, 9.3, 'Tim Robbins, Morgan Freeman', 1, 142),
    (2, 'Inception', 2010, 2, 8.8, 'Leonardo DiCaprio, Joseph Gordon-Levitt', 2, 148),
    (3, 'Pulp Fiction', 1994, 3, 8.9, 'John Travolta, Uma Thurman', 3, 154),
    (4, 'The Dark Knight', 2008, 1, 9.0, 'Christian Bale, Heath Ledger', 2, 152),
    (5, 'Fight Club', 1999, 4, 8.8, 'Brad Pitt, Edward Norton', 4, 139);

-- Vlozeni dat do tabulky Directors
INSERT INTO Directors 
  (DirectorID, FirstName, LastName, DateOfBirth, CountryOfOrigin)
  VALUES
    (1, 'John', 'Smith', '1980-05-10', 'USA'),
    (2, 'Emily', 'Johnson', '1975-08-15', 'UK'),
    (3, 'Michael', 'Williams', '1982-03-22', 'Canada');

-- Vlozeni dat do tabulky Actors
INSERT INTO Actors 
  (ActorID, FirstName, LastName, DateOfBirth, CountryOfOrigin)
  VALUES
    (1, 'Tom', 'Hanks', '1956-07-09', 'USA'),
    (2, 'Brad', 'Pitt', '1963-12-18', 'USA'),
    (3, 'Jennifer', 'Lawrence', '1990-08-15', 'USA'),
    (4, 'Emma', 'Stone', '1988-11-06', 'USA'),
    (5, 'Leonardo', 'DiCaprio', '1974-11-11', 'USA');

-- Vlozeni dat do tabulky Genres
INSERT INTO Genres 
  (GenreID, Name)
  VALUES
    (1, 'Drama'),
    (2, 'Action'),
    (3, 'Comedy'),
    (4, 'Thriller');

-- Vlozeni dat do tabulky Users
INSERT INTO Users 
  (UserID, FirstName, LastName, Email, Password)
  VALUES
    (1, 'John', 'Doe', 'john@example.com', 'password1'),
    (2, 'Jane', 'Smith', 'jane@example.com', 'password2'),
    (3, 'Michael', 'Johnson', 'michael@example.com', 'password3');

-- Vlozeni dat do tabulky Ratings
INSERT INTO Ratings 
  (RatingID, MovieID, UserID, Rating)
  VALUES
    (1, 1, 1, 4.8),
    (2, 1, 2, 4.5),
    (3, 2, 1, 3.7),
    (4, 2, 3, 4.2),
    (5, 3, 2, 4.3),
    (6, 4, 3, 3.9),
    (7, 5, 1, 4.7),
    (8, 5, 3, 4.9);

-- Vlozeni dat do tabulky FavoriteMovies
INSERT INTO FavoriteMovies 
  (FavoriteID, UserID, MovieID)
  VALUES
    (1, 1, 1),
    (2, 1, 3),
    (3, 2, 2),
    (4, 3, 4),
    (5, 3, 5);

-- Vlozeni dat do tabulky Reviews
INSERT INTO Reviews 
  (ReviewID, UserID, MovieID, ReviewText, ReviewDate)
  VALUES
    (1, 1, 1, 'Great movie!', '2022-05-15'),
    (2, 2, 1, 'Loved the performances.', '2022-05-18'),
    (3, 1, 2, 'Action-packed and thrilling.', '2022-05-20'),
    (4, 3, 3, 'Funny and entertaining.', '2022-05-22'),
    (5, 2, 4, 'Good storyline.', '2022-05-25'),
    (6, 3, 5, 'Amazing performances by the actors.', '2022-05-28');
