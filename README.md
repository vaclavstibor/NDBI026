# NDBI026
Database applications development (2022/23)

# Schéma filmové databáze

## 1. Movies
    - MovieID (primary key)
    - Title
    - ReleaseYear
    - Director
    - MainActors
    - Genre
    - Duration
    
## 2. Directors
    - DirectorID (primary key)
    - FirstName
    - LastName
    - DateOfBirth
    - CountryOfOrigin
    
## 3. Actors
    - ActorID (primary key)
    - FirstName
    - LastName
    - DateOfBirth
    - CountryOfOrigin
    
## 4. Genres
    - GenreID (primary key)
    - Name
    
## 5. Table Ratings
    - RatingID (primary key)
    - MovieID (foreign key referencing the "Movies" table)
    - Rating (numeric value)

## 6. Users    
    - UserID (primary key)
    - FirstName
    - LastName
    - Email
    - Password
    
## 7. FavoriteMovies
    - FavoriteID (primary key)
    - UserID (foreign key referencing the "Users" table)
    - MovieID (foreign key referencing the "Movies" table)
    
## 8. Reviews
    - ReviewID (primary key)
    - UserID (foreign key referencing the "Users" table)
    - MovieID (foreign key referencing the "Movies" table)
    - ReviewText
    - ReviewDate

---

Filmová databáze
---

- Každý film v databázi má název, rok vydání a je režírován konkrétním režisérem.   
    - Dále se u filmů evidují informace o hlavních hercích, žánru a délce. 
    - Filmy jsou identifikovány pomocí unikátního MovieID.      

- Režiséři jsou identifikováni pomocí unikátního DirectorID. 
    - Kromě jména a příjmení režisérů se také eviduje jejich datum narození a země původu.

- Herci jsou identifikováni pomocí unikátního ActorID. 
    - Každý herec má jméno, příjmení, datum narození a zemi svého původu.

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
  - Reaguje na vložení nových filmů do tabulky Movies a přidává nové herce do tabulky Actors na základě herců uvedených ve vkládaném filmu. 
  - Ověří, zda herci již existují v tabulce Actors a vloží nové herce, pokud neexistují.
