-- Filmova databaze

/*
Filmova databaze
----------------

- Každý film v databázi má název, rok vydání a je režírován konkrétním režisérem.   
    - Dále se u filmů evidují informace o hlavních hercích, žánru a délce. 
    - Filmy jsou identifikovány pomocí unikátního MovieID.      

- Režiséři a herci (případně další členové týmu podílejícím se na tvorbě dilmu) jsou obsaženi tabulce CastAndCrew.
    - Každá osoba má své jméno, příjmení, datum narození, zemi svého původu a identifikaci své role v týmu.

- Filmy jsou zařazeny do různých žánrů.

- Pro hodnocení filmů je dostupná tabulka Ratings obsahující unikátní RatingID. 
    - Každé hodnocení je spojeno s konkrétním filmem pomocí MovieID a obsahuje číselnou hodnotu v uzavřeném intervalu od 0 do 5.

- Uživatelé filmové databáze jsou evidováni v tabulce Users s unikátním UserID. 
    - Každý uživatel má jméno, příjmení, email a heslo.

- Oblíbené filmy uživatele jsou zaznamenány v tabulce FavoriteMovies.
    - Tato tabulka spojuje uživatele a filmy pomocí UserID a MovieID.

- Pro recenze filmů se vytváří tabulka Reviews s unikátním ReviewID. 
    - Každá recenze je spojena s uživatelem pomocí UserID a s filmem pomocí MovieID. 
    - Recenze obsahuje textový obsah recenze a datum, kdy byla napsána.

Správa databaze
---------------

- Každý uživatel může vytvořit hodnocení určitého filmu. (AddMovieRating)
    - Uživatel předává ID filmu z databáze, své vlastní ID a hodnocení filmu v rozmezí od 1 do 5. 
    - Informace se zaznamenají do tabulky Ratings, která uchovává hodnocení filmů od všech uživatelů.
    - Každý uživatel může mít pouze jedno hodnocení k jednomu filmu.

- Každý uživatel může přidat recenzi k určitému filmu. (AddMovieReview)
    - Uživatel zadává ID filmu z databáze, své vlastní ID, text recenze a datum, kdy byla recenze vytvořena. 
    - Informace jsou následně uloženy do tabulky Reviews, která uchovává textové recenze od uživatelů k daným filmům.
    - Každý uživatel může mít pouze jednu recenzi k jednomu filmu.

- Každý uživatel může zobrazit své i ostatních uživatelů oblíbené filmy. (GetUserFavoriteMovies) 
    - Uživatel předává své vlastní nebo někoho jiného ID a dostane filmy, které jsou označeny jako oblíbené pro daného uživatele.
    - Vyhledávání probíhá pomocí ID uživatele nebo vyplněním jeho jména. Pokud neexistuje dojde k informování o absenci jeho záznamu v databázi.

- Každý uživatel může přidat film do svých oblíbených. (AddFavoriteMovie)
    - Uživatel zadává své vlastní ID a ID filmu, který chce přidat do oblíbených. 
    - Tyto informace se vkládají do tabulky FavoriteMovies, což umožňuje uživatelům uchovávat seznam jejich oblíbených filmů.
    - Každý uživatel má vedený záznam oblíbeném filmu v tabulce pouze jednou.

- Každý uživatel má také právo k odstranění filmu ze svého seznamu oblíbených. (RemoveFavoriteMovie)
    - Uživatel zadává své vlastní ID a ID filmu, který chce odstranit z oblíbených. 
    - Tím odstraní příslušný záznam z tabulky FavoriteMovies, čímž aktualizuje svůj seznam oblíbených filmů.
    - Pokud uživatel nemá film mezi oblíbenými, bude po pokusu o odstranění daného filmu z oblíbených informován, že takový záznam o oblíbenosti v databázi neexistuje.

Zobrazení databáze
------------------

- GetMovieReviews
    - Umožňuje získat všechny recenze týkající se určitého filmu. 
    - Návštěvník/uživatel předává ID filmu jako vstup a výstupem je seznam recenzí, obsahující identifikátory uživatelů, jejich jména, text recenzí a datum jejich vytvoření. 

- SearchMoviesByReleaseYear
    - Umožňuje vyhledávat filmy podle jejich roku vydání. 
    - Návštěvník/uživatel podle konkrétního roku vydání získá filmy, které byly vydány právě v tomto roce.

- GetTopMoviesByGenre
    - Slouží k zobrazení deseti nejlépe hodnocených filmů daného žánru. 
    - Návštěvník/uživatel pomocí ID žánru dostane TOP 10 filmů seřazených podle jejich průměrného hodnocení od nejlepšího po nejhorší. 
    
- SearchMoviesByActor 
    - Umožňuje vyhledání filmů obsahující konkrétního herce. 
    - Návštěvník/uživatel vyplní jméno a příjmení herce a výstupem dostane filmy, ve kterých se tento herec objevuje. 

Poznámky
--------

- Trigger UpdateAveraRating
  - Aktualizuje průměrná hodnocení filmů v tabulce Movies na základě nových hodnocení vložených, upravených nebo smazaných záznamů v tabulce Ratings.

- Trigger AddNewActors
  - Reaguje na vložení nových filmů do tabulky Movies a přidává nové herce do tabulky CastAndCrew na základě herců uvedených ve vkládaném filmu. 
  - Ověří, zda herci již existují v tabulce CastAndCrew a vloží nové herce, pokud neexistují.

*/

CREATE TABLE Users (
  UserID int PRIMARY KEY,
  FirstName nvarchar(30) NOT NULL,
  LastName nvarchar(30) NOT NULL,
  Email nvarchar(60) NOT NULL UNIQUE
    check (Email like '%_@_%.__%'),
  Password nvarchar(60)
);

CREATE TABLE CastAndCrew (
  PersonID INT IDENTITY(1,1) PRIMARY KEY,
  FirstName nvarchar(60) NOT NULL,
  LastName nvarchar(60) NOT NULL,
  DateOfBirth DATE,
  CountryOfOrigin varchar(60),
  PersonType varchar(10) NOT NULL, -- 'Actor' or 'Director'
  constraint U_PersonType_FirstName_LastName UNIQUE (PersonType, FirstName, LastName)
);

CREATE TABLE Genres (
  GenreID int PRIMARY KEY,
  Name varchar(30) NOT NULL
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
    check (Duration > 0),
  FOREIGN KEY (DirectorID) REFERENCES CastAndCrew (PersonID),
  FOREIGN KEY (GenreID) REFERENCES Genres (GenreID)
);

CREATE TABLE Ratings (
  RatingID int PRIMARY KEY,
  MovieID int NOT NULL,
  UserID int NOT NULL,
  Rating decimal(2,1) NOT NULL
    check (Rating >= 0 AND Rating <= 5),  
  FOREIGN KEY (MovieID) REFERENCES Movies (MovieID) ON DELETE CASCADE,
  FOREIGN KEY (UserID) REFERENCES Users (UserID) ON DELETE CASCADE
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