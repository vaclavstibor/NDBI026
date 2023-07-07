# NDBI026
Database applications development (2022/23)

# Připomínky

- [x] Nestálo by za to, aby některé cizí klíče měly nějakou non-default ON DELETE klauzuli?
    - **> OPRAVENO. Máte pravdu, stálo.**
- [x] *Opravdu chcete dovolit, aby jeden uživatel hodnotil jeden film vícekrát? Možná to samé u Reviews.*
  - *Aha, podle procedur AddMovieRating/AddMovieReview vidím, že ne. Bezpečnější by bylo mít index nad dvojicí cizích klíčů unikátní (ještě lépe UNIQUE omezení)*
    - **> OPRAVENO.**
- [x] *Directors a Actors jsou natolik podobné/stejné, že by možná stálo za to je chápat jako součást nějaké hierarchie.*
    - **> OPRAVENO. Directos a Actors sločeni do jedné tabulky CastAndCrew.**
- [x] *Nebude ten TRIGGER UpdateAverageRating zbytečně pomalý, když bude po každém novém ratingu všechno přepočítávat?*
    - **> OPRAVENO. Aktualizace průměrného hodnocení pouze pro filmy, kterých se přidané hodnocení týká.**
- [x] *Bude řešení, použité v TRIGGER AddNewActors bezpečné, pokud se bude vkládat paralelně více filmů? Varianta se SELECT MAX+1 mi přijde podezřelá.*
    - **> OPRAVENO. Použití SCOPE_IDENTITY()**
- [ ] *U procedur pro zobrazení je otázka, jestli by nebyla funkce, vracející tabulku, lepším řešením. Dalo by se nad tím dělat další SELECTy. Proti mluví ale zase to, že se funkce v MSSQL ne zcela šťastně volají s nutností kvalifikovat je vlastníkem.*
    - **> Pokud bychom chtěli na ni dělat další SELECTy**
- [ ] *Je k něčemu pohled MovieRatings_VW, když vrací jen data z jedné tabulky?*
    - **> Ano, dá se na něj jednoduššeji odkázat. Přehlednější zápis požadované akce, která svým pojmenování jednoznačná a přehledná, pokud uvažujeme, že ji chceme někdy v budoucnu používat (např. jako nějaké API).**

# Schéma filmové databáze

## 1. Movies
    - MovieID (primary key)
    - Title
    - ReleaseYear
    - Director
    - MainActors
    - Genre
    - Duration
    
## 2. CastAndCrew
    - PersonID (primary key)
    - FirstName
    - LastName
    - DateOfBirth
    - CountryOfOrigin
    - PersonType

## 3. Genres
    - GenreID (primary key)
    - Name
    
## 4. Table Ratings
    - RatingID (primary key)
    - MovieID (foreign key referencing the "Movies" table)
    - Rating (numeric value)

## 5. Users    
    - UserID (primary key)
    - FirstName
    - LastName
    - Email
    - Password
    
## 6. FavoriteMovies
    - FavoriteID (primary key)
    - UserID (foreign key referencing the "Users" table)
    - MovieID (foreign key referencing the "Movies" table)
    
## 7. Reviews
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
  - Reaguje na vložení nových filmů do tabulky Movies a přidává nové herce do tabulky Actors na základě herců uvedených ve vkládaném filmu. 
  - Ověří, zda herci již existují v tabulce Actors a vloží nové herce, pokud neexistují.
