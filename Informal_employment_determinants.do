cd "C:\Users\DELL\Desktop\Recherche\RECHERCHES\RECHERCHES\THESE\depouille\Aller à nouveau de l'avant\REDACTION\REGRESSION"

log using "C:\Users\DELL\Desktop\Recherche\RECHERCHES\RECHERCHES\THESE\depouille\Aller à nouveau de l'avant\REDACTION\REGRESSION\Resultats\log"
********************************************************************************
//PROJECT TITLE: Analyse des déterminants de l'emploi informel en Côte d'Ivoire														
//CREATED BY   : Sawadogo Jean Bruno
//CREATION DATE: March 01, 2025
//DATE LAST REVISED: June 16, 2025
//TABLE OF CONTENT:
	*DICTIONARY DICTIONARY OF MEAN VARIABLES
	*PART I   : DATA ARRANGEMENT
	*PART II  : CREATION OF INDICATIORS
	*PART III : DESCRIPTIVE STATISTICS
	*PART IV  : TESTS AND REGRESSIONS
	
********************************************************************************	
********************************************************************************
** DICTIONARY OF MEAN VARIABLES
		*Indice d'informalité chez les travailleure non-salariés	: informel_1
		*Indice d'informalité chez les travailleure salariés		: informel_2
		*Informel						 							: registre
		*Type de contrat											: Contrat_ecrit
		*Education													: diplom_3
		*sexe														: sexe_0 
		*Age														: age_cut1
		*Branche d'activité	(Type d'admin)							: branch_0
		*Milieu de résidence										: milieu_R
		*CSP														: Csp_sep
		*nationalité 												: natio
		*CSP du parent												: csp_parent2
		*le niveau d'éducation du parent							: edu_parent
		*Statut matrimonial de l'indiv								: statut_matrimonial

		
		*************************************************************************

version 17
clear all
set more off

*Raw data: available through World Bank Open Data at "https://microdata.worldbank.org"


********************************************************************************
********************************************************************************
//PART I: DATA ARRANGEMENT

***Section 1 : Merging databases

use "C:\Users\E682\Desktop\Données ENV\CIV_2021_EHCVM-2_v01_M_STATA14\s04b_me_civ2021.dta" //ouvrir la deuxième base emploi de l'ENV 2021

merge 1:1 vague grappe menage membres__id using "C:\Users\E682\Desktop\Données ENV\CIV_2021_EHCVM-2_v01_M_STATA14\s02_me_civ2021.dta"//la combine avec la base éducation avec les varibles "vague" "grappe" "menage" "membres__id".
drop _merge // enlever le _merge creé afin de pouvoir matcher la presente base avec une autre 

merge 1:1 vague grappe menage membres__id using "C:\Users\E682\Desktop\Données ENV\CIV_2021_EHCVM-2_v01_M_STATA14\s04c_me_civ2021.dta"// la combine avec la deuxième base emploi avec les varibles "vague" "grappe" "menage" "membres__id"

merge m:1 vague grappe menage using "C:\Users\DELL\Desktop\Recherche\RECHERCHES\RECHERCHES\DATA_BANK\ENQUETE SUR LE NIVEAU DE VIE\EHCVM 2022\CIV_2021_EHCVM-2_v01_M_STATA14\s20b_1_me_civ2021.dta"
drop _merge

***Section 2 : Premier recodage des variables d'intérêts et de contrôles
*  recodage des variables sociodémographique
codebook milieu
recode milieu (1=1) (2=0), generate (milieu_R)
tab milieu milieu_R, missing

tab sexe
recode sexe (1=1) (2=0), generate (sexe_0)
tab sexe sexe_0, missing

tab branch
recode branch (1/2=99) (3/5=0) (6=1) (7/11=2), generate(branch_0)
tab branch branch_0, missing

tab nation
recode nation (3=0) (5/18=0) (4=1), generate (natio)//la variable nationalité binaire
tab nation natio, missing

tab s01q07
recode s01q07 (2/3=1) (4/7=0) (1=0), generate (statut_matrimonial)
tab s01q07 statut_matrimonial, missing

tab diplome
recode diplome (0=0) (1=1) (2/5=2) (6/10=3), generate (diplom_3)
tab diplome diplom_3, missing

sum age
recode age (0/25=1) (26/45=2) (46/150=3), generate (age_cut)
tab age_cut

tab s04q39
recode s04q39 (1/8=1) (9/10=0), generate (Csp_sep)
tab s04q39 Csp_sep, missing

tab s20bq13c
recode s20bq13c (1/2=1) (3/4=0), generate (corruption_perc)
tab s20bq13c corruption_perc, missing

label define lab_corr 0"Pas corrompu" 1"Corrompu"
label values corruption_perc lab_corr

recode s20bq13c (1=1) (2/4=0), generate (corruption_perc_1)

recode s20bq13c (2=1) (1=0) (3/4=0), generate (corruption_perc_2)

recode s20bq13c (3=1) (1/2=0) (4=0), generate (corruption_perc_3)

recode s20bq13c (1/3=0) (4=1), generate (corruption_perc_4)






*  création des variables "Csp du parent" et "Niveau d'éducation du parent'"
gen csp_parent1=s01q27
replace csp_parent1=s01q34  if missing(s01q27)
recode csp_parent1 (1/8=1) (9/1=2) (11=0), generate (csp_parent)
recode csp_parent (0=0) (1=1) (9/10=2), gen (csp_parent2)

recode csp_parent (0=0) (1=1) (9/10=2), gen (csp_parent_recoded)

gen edu_parent1=s01q25
replace edu_parent1=s01q32 if missing(s01q25)
recode edu_parent1 (1=0) (6=0) (2=1) (3/4=2) (5=3), generate (edu_parent)

gen branch_parent1= s01q26 
replace branch_parent1=s01q33  if missing(s01q26 )
recode branch_parent1 (1/2=1) (3/4=2) (5=3) (6=4) (7/8=5) (9=6) (10=0) (0=0), generate(branch_parent)

*  Recodage des variables servant à calculer les indices d'informalité
recode s04q39b (2=0) (1=1), generate (fisc)
recode s04q39a (2=0) (1=1), generate (compta_formelle)
recode s04q38 (2=0) (1=1), generate (cotisation_sociale)
recode s04q33 (2=0) (1=1), generate (conge_paye)
recode s04q35 (2=0) (1=1), generate (conge_maladie)
recode s04q40 (2=0) (1=1), generate (conge_maternité)
recode s04q42 (2=0) (1=1), generate (bulletin_salaire)
recode s04q44 (2=0) (1=1), generate (prime)
recode s04q46 (2=0) (1=1), generate (A_avantages)

* Recodage de la variable de pondération
gen wgt_0=hhweight/466.54074 //VARIABLE DE PONDERATION AU PRORATA DE L'ECHANTILLON


********************************************************************************
//PART II: CREATION OF INDICATIORS

***Section 1 : Indice 0 d'informel
gen informel_0=fisc
replace informel_0=1 if (fisc==1|compta_formelle==1) //Informel bianaire 

***Section 2 : Indice 1, réservé aux travailleurs non-salariés (employeurs, patron et travailleurs pour compte propre)
gen informel_1=.
replace informel_1=fisc+compta_formelle+cotisation_sociale if (activ12m==1|activ12m==2) // informel_1 est l'outcome d'interêt qui prend quatre modalités allant de 0 à 3 avec 0 pour Très informel et 3 pour purement formel. Il faut noter que cette variable est exclusive aux travailleurs non-salariés(employeurs, patron et travailleurs pour compte propre)

replace informel_1=2 if informel_1==3// ce recodage a été effectué etant donné que la modalité 3 à une faible fréquence (5)
recode informel_1 (0=0) (1/2=1) (3=2), generate (informel_1_1) //La variable informel_1_1 est une variable à trois modalités de sorte que tous ceux qui remplissent au moins deux critères de formalité prennent la modalité de milieu (1) la variable a donc trois modalités(0, 1 et 2) elle est utilisée pour la stat descriptive et au cas où la première variable ne donne pas satisfaction.
recode informel_1 (0=0) (1/2=1), gen(inf_binary)
gen inf_c=1-inf_binary

************************************************************************************************

gen form_r=.
replace form_r=fisc+cotisation_sociale if (activ12m==1|activ12m==2) 
gen informal_corrected=2-form_r
replace informal_corrected=1 if informal_corrected==0
******************************************************************************************************************



***Section 2 : Indice 2, réservé aux travailleurs salariés (voir ...........)

***Section 3 : Indice 3, réservé aux travailleurs salariés
*informel_3 réservé aux travailleurs salariés. Il sert à vérifier si la varible informel a été correctement créée.
gen informel_3=.
replace informel_3=cotisation_sociale+conge_paye+conge_maladie+conge_maternité+bulletin_salaire+A_avantages if (activ12m==1|activ12m==2)  

recode informel_3 (0=0) (1/5=1) (6=2), generate (informel_3_1) //La variable informel_1_1 est une variable à trois modalités de sorte que tous ceux qui remplissent au moins deux critères de formalité prennent la modalité de milieu (1) la variable a donc trois modalités(0, 1 et 2) elle est utilisée pour la stat descriptive et au cas où la première variable ne donne pas satisfaction.

// Regarder la fréquence selon les niveaux de formalité-exportation excel ()


cd "C:/Users/DELL/Desktop/Presentations respectives/Presantation Prof Mourifié/"

asdoc tab informel_3 if (activ12m==1|activ12m==2) & branch>2 & age>14 & Csp_sep==1 [iw=wgt_0], save(Freq.doc) replace title(Fréquence des niveaux de formalité des travailleurs salariés)

asdoc tab informel_1 if (activ12m==1|activ12m==2) & branch>2 & age>14 & Csp_sep==0 [iw=wgt_0], append title(Fréquence des niveaux de formalité des travailleurs non-salariés)


********************************************************************************
//PART III: DESCRIPTIVE STATISTICS

***Section 0: Variable de filtrage
*Les variables de filtrage sont utilisé pour renvoyer des resultats que pour la sous bases qui ne contiennent aucune valeur manquante les variables crées ici sont nomiss,nomiss1 et nomiss0
egen missing= rowmiss (informel_1 diplom_3 age statut_matrimonial branch_0 milieu_R sexe_0 csp_parent edu_parent branch_parent natio branch_0)
gen nomiss=(missing==0)

egen missing1= rowmiss (informel_2 diplom_3 age statut_matrimonial branch_0 milieu_R sexe_0 csp_parent edu_parent branch_parent natio branch_0)
gen nomiss1=(missing1==0)

egen missing0= rowmiss (informel_0 diplom_3 age statut_matrimonial branch_0 milieu_R sexe_0 csp_parent edu_parent branch_parent natio branch_0)
gen nomiss0=(missing1==0)

***Section 1: Summarize
asdoc sum informel_1 diplom_3 age statut_matrimonial milieu_R sexe_0 csp_parent2 edu_parent natio branch_0 if (activ12m==1|activ12m==2) & branch>2 & Csp_sep==0 & nomiss==1 & age>14 [iw=wgt_0], save(summary_var1.doc) 

asdoc sum informel_2 diplom_3 natio age statut_matrimonial  milieu_R sexe csp_parent2 edu_parent branch_0 if (activ12m==1|activ12m==2) & branch>2 & Csp_sep==1 & nomiss0==1 [iw=wgt_0], save(summary_var2.doc)

***Section 2: Tabulation
*Il est important ici d'indiquer le chemin des résultats de tabulation
cd "C:\Users\DELL\Desktop\Recherche\RECHERCHES\RECHERCHES\THESE\depouille\Aller à nouveau de l'avant\REDACTION\REGRESSION\Resultats\Sortie Word"

*la fonction asdoc est utilisée ici pour exporter la tab dans le fichier word "Freq1.doc"
sort Csp_sep

asdoc by Csp_sep: tab diplom_3 if (activ12m==1|activ12m==2) & branch>2 & age>14 [iw=wgt_0], save(Freq1.doc) replace title(freq_edu)

asdoc by Csp_sep: tab statut_matrimonial natio if (activ12m==1|activ12m==2) & branch>2 & age>14 [iw=wgt_0], append title(statut_matrimonial)

asdoc by Csp_sep: tab milieu_R if (activ12m==1|activ12m==2) & branch>2 & age>14 [iw=wgt_0], append title(milieu_R)

asdoc by Csp_sep: tab sexe if (activ12m==1|activ12m==2) & branch>2 & age>14 [iw=wgt_0], append title(sexe)

asdoc by Csp_sep: tab csp_parent2 if (activ12m==1|activ12m==2) & branch>2 & age>14 [iw=wgt_0], append title(csp_parent)

asdoc by Csp_sep: tab edu_parent if (activ12m==1|activ12m==2) & branch>2 & age>14 [iw=wgt_0], append title(edu_prent)

asdoc by Csp_sep: tab natio if (activ12m==1|activ12m==2) & branch>2 & age>14 [iw=wgt_0], append title(natio)

asdoc by Csp_sep: tab branch_0 if (activ12m==1|activ12m==2) & branch>2 & age>14 [iw=wgt_0], append title(branch)


***Section 3: Corrélation
pwcorr informel_1 diplom_3 age_cut statut_matrimonial milieu_R sexe_0 csp_parent edu_parent natio branch_0 if (activ12m==1|activ12m==2) & branch>2 & Csp_sep==0 & nomiss==1 & age>14, star(5)

pwcorr informel_2 diplom_3 age_cut statut_matrimonial milieu_R sexe_0 csp_parent edu_parent natio branch_0 if (activ12m==1|activ12m==2) & branch>2 & Csp_sep==1 & nomiss0==1 & age>14, star(5)


********************************************************************************
//PART IV: TESTS AND REGRESSIONS

***Section 1: Tests de parallelisme de pentes
*Le test de paraléllisme des pentes ou le test de ratios proportionels permet de choisir entre un modèle logistique ordonné et un modèle logistique ordonné généralisé, le dernier permettant de aux coefficients de varier en fonction du niveau de formalité. Si le p-value est significative (inférieure à 0,05) alors le modèle gologit2 est plus indiqué pour la regression dans le cas contraire le ologit est plus indiqué.

*Test 1: informel 1
ologit informel_1 i.diplom_3 age_cut i.statut_matrimonial i.milieu_R i.sexe_0 i.csp_parent i.edu_parent i.branch_0 i.natio if (activ12m==1|activ12m==2) & branch>2 & Csp_sep==0 & nomiss==1 & age>14 , nolog vce (robust)
oparallel, ic
asdoc oparallel, save(oparallel_1.doc)

brant, detail
asdoc brant, save(brant_1.doc)

*Test 2: informel 2
ologit informel_2 i.diplom_3 age_cut i.statut_matrimonial i.milieu_R i.sexe_0 i.csp_parent2 i.edu_parent i.branch_0 i.natio if (activ12m==1|activ12m==2) & branch>2 & Csp_sep==1 & nomiss0==1 & age>14 , nolog vce (robust)

oparallel, ic
asdoc oparallel, save(oparallel_2.doc)

brant, detail
asdoc brant, save(brant_2.doc)

***Section 1: Regression
** Regression chez les non-salariés
gologit2 informel_1 i.diplom_3 i.age_cut1 i.statut_matrimonial i.milieu_R i.sexe_0 i.csp_parent2 i.edu_parent i.branch_0 i.natio if (activ12m==1|activ12m==2) & branch>2 & Csp_sep==0 & nomiss==1 & age>14 [iw=wgt_0], nolog robust
outreg2 using resultats_informel_revised.doc, dec (3) ctitle("Modèle 0: Non-salariés")

gologit2 informel_1 i.diplom_3 i.age_cut1 i.statut_matrimonial i.milieu_R i.sexe_0 i.csp_parent2 i.edu_parent i.branch_0 i.natio if (activ12m==1|activ12m==2) & branch>2 & Csp_sep==0 & nomiss==1 & age>14 [iw=wgt_0], nolog robust or
outreg2 using resultats_informel_revised_OR.doc, replace eform ctitle("odds Ratio")  dec (3)

mchange
asdoc mchange, save(model1.doc)

** Regression chez les salariés
gologit2 informel_2 i.diplom_3 i.age_cut1 i.statut_matrimonial i.milieu_R i.sexe_0 i.csp_parent2 i.edu_parent i.branch_0 i.natio if (activ12m==1|activ12m==2) & branch>2 & Csp_sep==1 & nomiss0==1 & age>14 [iw=wgt_0], nolog robust
outreg2 using resultats_informel_revised.doc, append eform ctitle("odds Ratio")

gologit2 informel_2 i.diplom_3 i.age_cut1 i.statut_matrimonial i.milieu_R i.sexe_0 i.csp_parent2 i.edu_parent i.branch_0 i.natio if (activ12m==1|activ12m==2) & branch>2 & Csp_sep==1 & nomiss0==1 & age>14 [iw=wgt_0], nolog robust or
outreg2 using resultats_informel_revised_OR.doc, dec (3) append ctitle("OR salariés")

mchange
asdoc mchange, save(model2_revised.doc)

save "C:\Users\DELL\Desktop\Recherche\RECHERCHES\RECHERCHES\THESE\depouille\Aller à nouveau de l'avant\REDACTION\REGRESSION\DONNEES\EHCVM_2021_sortie.dta"

log close