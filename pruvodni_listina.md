# Průvodní listina projektu

## 1. Popis projektu

Tento projekt se zabývá analýzou dostupnosti základních potravin pro obyvatelstvo v kontextu vývoje mezd v čase. Cílem analytického týmu bylo zodpovědět několik výzkumných otázek zaměřených na to, jak se v průběhu let mění průměrné mzdy a ceny vybraných základních potravin v České republice.

Výsledky mají posloužit tiskovému oddělení k prezentaci na odborné konferenci zaměřené na životní úroveň a dostupnost potravin. Kolegové definovali konkrétní otázky, které se týkají:

- Růstu mezd v různých odvětvích
- Množství potravin (mléka a chleba), které si lze koupit za průměrnou mzdu v čase
- Tempa zdražování potravin v různých kategoriích
- Extrémních výkyvů v růstu cen potravin vůči mzdám
- Vlivu makroekonomického ukazatele (HDP) na mzdy a ceny potravin

K dosažení tohoto cíle bylo zapotřebí připravit robustní datové podklady. Konkrétně jsme vytvořili dvě výsledné tabulky:

- **Primární tabulku** s údaji za Českou republiku (propojující data o mzdách a cenách potravin ve společném časovém období)
- **Sekundární tabulku** s doplňkovými makroekonomickými daty pro další evropské státy (HDP, koeficient GINI a populace)

Následně byly nad těmito tabulkami provedeny SQL dotazy, které poskytly data k zodpovězení jednotlivých výzkumných otázek. Všechny postupy a zjištění jsou popsány níže, včetně případných nesrovnalostí v datech a samotných odpovědí podložených datovými výsledky.

## 2. Tvorba primární a sekundární tabulky

### Primární tabulka (t_jiri_nemec_project_SQL_primary_final)

Primární datová tabulka obsahuje sjednocené informace o průměrných mzdách a cenách vybraných potravin v České republice, omezené na stejné časové období.

**Data o mzdách** pocházejí z datasetu `czechia_payroll` (Portál otevřených dat ČR) a byla filtrována tak, aby zahrnovala pouze relevantní ukazatel – konkrétně průměrnou hrubou mzdu v Kč (hodnota s kódem 5958, přepočtené osoby, jednotka Kč). Tato mzda byla agregována po jednotlivých letech a to jednak pro každé odvětví ekonomiky zvlášť (dle číselníku odvětví), jednak jako celek za celou ČR (označeno jako "Celkem").

**Data o cenách potravin** pocházejí z datasetu `czechia_price` (také z otevřených dat ČR); jelikož jsou dostupná v podobě týdenních cen z různých regionů, byla převedena na průměrné roční ceny pro jednotlivé potraviny v celostátním měřítku.

Následně jsme provedli propojení mezd a cen přes sloupec rok – do primární tabulky byly zahrnuty pouze ty roky, pro které existují data jak o mzdách, tak o cenách (tj. průnik období obou zdrojů). Tím vzniklo společné období **2006–2018**, které primární tabulka pokrývá.

Každý z těchto roků obsahuje záznamy kombinující konkrétní odvětví a konkrétní potravinu s příslušnou průměrnou mzdou a průměrnou cenou.

> **Poznámka:** Data v primární tabulce nebyla nijak dodatečně upravována – hodnoty odpovídají zdrojovým datům po agregaci. U některých položek nemusí být dostupné hodnoty pro všechny roky (např. určitá potravina se mohla začít sledovat později), avšak tabulka zahrnuje všechny kombinace, kde data pro daný rok existují. V jednom roce (2013) byl patrný mírný pokles průměrné mzdy (viz dále), jinak však data vykazují očekávané trendy.

### Sekundární tabulka (t_jiri_nemec_project_SQL_secondary_final)

Tato tabulka obsahuje makroekonomické ukazatele evropských zemí – konkrétně hrubý domácí produkt (HDP v běžných cenách), GINI koeficient nerovnosti příjmů a počet obyvatel.

Data byla převzata z datasetů `economies` (globální ekonomická data) a `countries` (seznam zemí a jejich kontinentů). Pro sestavení sekundární tabulky jsme nejprve vybrali všechny státy, které spadají do Evropy (dle příznaku kontinentu v číselníku zemí). K ekonomickým datům těchto států jsme pak přiřadili pouze roky **2006–2018**, abychom se sladili s časovým rozsahem primární tabulky pro ČR.

Výsledná tabulka tedy pro každou evropskou zemi obsahuje ročně HDP, GINI a populaci, pokud byly v daném roce dostupné.

> **Poznámka:** V datech se objevují některé neúplné hodnoty, zejména u koeficientu GINI (který nebyl pro všechny země a roky měřen – v takových případech zůstává hodnota prázdná). HDP a populace jsou většinou k dispozici pro všechny sledované roky u drtivé většiny evropských států.

Tato sekundární tabulka slouží primárně k tomu, aby bylo možné porovnat makroekonomický kontext jednotlivých zemí, případně využít data pro ČR při zodpovídání výzkumné otázky o vlivu HDP.

## 3. Výzkumné otázky a odpovědi na ně

### 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

**Mzdy v průběhu sledovaných let rostly ve všech odvětvích** – žádné odvětví nemá v posledním roce nižší průměrnou mzdu než na počátku období. Každý sektor ekonomiky zaznamenal od roku 2006 do roku 2018 celkový nárůst průměrné mzdy.

Například odvětví s nejpomalejším růstem ("Ostatní činnosti" či "Administrativní a podpůrné činnosti") si i tak polepšila zhruba o 6–7 tisíc Kč v průměru za měsíc mezi lety 2006 a 2018.

Některá odvětví ovšem dočasně poklesla v určitých letech – typicky okolo období hospodářských potíží. Celková průměrná mzda v celé ekonomice například mírně klesla v roce 2013 (meziročně o cca 1,5 % oproti roku 2012), stejně tak v jednotlivých odvětvích byly zaznamenány drobné meziroční poklesy (např. stavebnictví, pohostinství či finance zaznamenaly menší pokles kolem roku 2009 nebo 2012–2013).

Tyto propady však byly pouze přechodné – dlouhodobý trend ve všech odvětvích je růstový a do roku 2018 mzdy ve všech sektorech převýšily úroveň z počátečního roku.

**Žádné odvětví tedy dlouhodobě neklesalo, pouze tempo růstu se liší** (někde mzdy rostly výrazně rychleji než jinde, ale všude byl zaznamenán celkový růst).

### 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

**Ve výchozím roce srovnání (2006)** lze za průměrnou měsíční mzdu nakoupit:
- Přibližně **1 257 kilogramů** konzumního chleba
- Zhruba **1 404 litrů** polotučného mléka

*(V roce 2006 byla průměrná mzda ~20 270 Kč a bochník chleba stál v průměru kolem 16,12 Kč za kg, litr mléka zhruba 14,44 Kč.)*

**V posledním dostupném roce (2018)** se díky růstu mezd a jen pozvolnému růstu cen 
dostupnost zlepšila a lze za průměrnou měsíční mzdu nakoupit:
- Přibližně **1 317 kilogramů** konzumního chleba
- Zhruba **1 611 litrů** polotučného mléka

*(V roce 2018 byla průměrná mzda ~31 931 Kč a bochník chleba stál v průměru kolem 24,24 Kč za kg, litr mléka zhruba 19,82 Kč.)*

**Porovnáním těchto dvou období** je vidět, že kupní síla vůči uvedeným základním potravinám vzrostla:
- Množství chleba, které si lze za mzdu koupit, stouplo zhruba o **60 kg**
- U mléka o přibližně **207 litrů**

**Vyjádřeno procentně**, v roce 2018 si průměrný zaměstnanec mohl dovolit asi o **5 % více chleba** a o **15 % více mléka** než v roce 2006.

**Dostupnost chleba i mléka se tedy zlepšila**, což značí, že mzdy rostly rychleji než ceny těchto dvou základních potravin v daném období.

### 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

**Nejpomalejší růst cen – dokonce prakticky záporný – byl zaznamenán u komodity cukr krystalový.** Průměrná cena cukru v analyzovaném období mírně klesala o cca **1,9 % ročně**, což z něj činí potravinu s vůbec nejnižším meziročním cenovým nárůstem (v tomto případě poklesem).

Velmi nízké tempo zdražování vykazovala také **rajčata (rajská jablka)**, u nichž došlo k nepatrnému průměrnému poklesu ceny **~0,7 % ročně**.

Z potravin, jejichž ceny rostly, zdražovaly nejpomaleji například:
- **Banány** (pouze ~0,8 % průměrně za rok)
- **Vepřové maso** (~1 % ročně)

Pro srovnání, většina ostatních sledovaných potravin zdražovala tempem okolo **2–4 % ročně**.

**Nejnižší cenový růst tedy měla kategorie cukru** (resp. cukr jako zástupce této kategorie základních potravin), který byl v průměru dokonce levnější než v předchozích letech.

### 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

**Na základě dat nebyl identifikován žádný rok, v němž by růst cen potravin překonal růst mezd o více než 10 procentních bodů.** V žádném roce sledovaného období se nestalo, že by inflace cen potravin o tolik převýšila mzdovou dynamiku.

**Největší zaznamenaný rozdíl** mezi tempem růstu cen potravin a mezd byl zhruba **6,6 p. b. v neprospěch mezd**, a to v roce 2013. V tomto roce:
- Ceny potravin vzrostly přibližně o **+5,1 %**
- Průměrné mzdy se reálně snížily o **−1,5 %**
- Rozdíl tedy činil oněch **~6,6 procentního bodu**

Tento rozdíl je výrazný, nicméně nedosahuje 10 % a je tak největším v rámci dat.

Ve většině ostatních roků se růst cen potravin pohyboval blízko růstu mezd nebo dokonce pod ním; často rostly mzdy a ceny srovnatelným tempem.

**Shrnutí:** Rok, kdy by meziroční zdražení potravin překročilo růst mezd o více než 10 %, se v dané datové řadě nevyskytuje.

### 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? (Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?)

**Částečně ano** – data naznačují, že výrazný růst HDP často souvisí s nadprůměrným růstem mezd, zejména v následujícím roce.

V několika případech, kdy HDP meziročně výrazně posílil (v našich datech definováno jako nad úroveň 75. percentilu růstu HDP), byl pozorován zrychlený růst mezd buď ve stejném roce, nebo častěji se zpožděním v roce následujícím.

**Příklady:**
- Po silném růstu HDP v roce 2017 (+5,17 %) byl v roce 2018 zaznamenán prudký růst mezd (meziročně cca +7,6 %), což naznačuje efekt ekonomického růstu z předchozího roku na mzdovou hladinu
- Rovněž v letech 2005–2007, kdy HDP ČR rostl nadprůměrným tempem (5–6 % ročně), došlo současně k vyšším přírůstkům průměrných mezd (mzdy tehdy rostly cca 6–8 % ročně)

Tyto příklady podporují myšlenku, že pokud ekonomika výrazně roste, firmy mají více prostředků na zvyšování platů a na trhu práce vzniká tlak na růst mezd, který se projevuje buď ihned, nebo s malým odstupem.

**Na druhou stranu, nejde o pravidlo bez výjimek** a vliv HDP na ceny potravin je ještě méně jednoznačný. Například v roce 2015 ekonomika ČR vyrostla o +5,4 % HDP, avšak mzdy v témže roce ani v roce následujícím nerostly nijak výjimečně rychle (meziroční růst mezd činil jen ~2,5 % v roce 2015 a ~3,7 % v roce 2016). Ceny potravin dokonce v roce 2015 mírně klesly (meziročně o –0,6 %), takže vysoký růst HDP se v tomto případě do spotřebitelských cen nepromítl vůbec.

**Obecně se ukazuje, že:**
- Výrazné zvýšení HDP má spíše viditelný vliv na **mzdy** (vyšší ekonomický růst často doprovází zrychlení růstu mezd, byť někdy až se zpožděním následující rok)
- U **cen potravin** je tato vazba méně spolehlivá

V některých letech s nadprůměrným HDP sice vidíme zrychlení inflace potravin (např. rok 2007 či 2017, kdy rostly HDP, mzdy i ceny potravin vyšším tempem), ale jindy vysoký růst HDP nepřinesl žádný výrazný cenový nárůst (viz zmíněný rok 2015).

**Shrnutí:** Vysoký růst HDP se v datech projevuje značnějším růstem mezd (často v následujícím roce), avšak u cen potravin není vliv HDP jednoznačný – může se projevit, ale často do hry vstupují i jiné faktory (např. zemědělské výkyvy, regulace cen, globální komoditní trendy), takže korelace mezi HDP a cenami potravin je slabší než mezi HDP a mzdami. 