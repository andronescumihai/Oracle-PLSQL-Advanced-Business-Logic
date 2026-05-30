<div align="center">

# 🏛️ Oracle PL/SQL — Art Gallery Advanced Business Logic

**A complete Oracle database programming system for an Art Gallery, built with stored procedures, triggers, packages, cursors, and custom exception handling.**

[![Oracle](https://img.shields.io/badge/Oracle-PL%2FSQL-F80000?style=for-the-badge&logo=oracle&logoColor=white)](https://www.oracle.com/)
[![SQL Developer](https://img.shields.io/badge/SQL_Developer-4.1%2B-4479A1?style=for-the-badge&logo=oracle&logoColor=white)](https://www.oracle.com/database/sqldeveloper/)
[![Academic](https://img.shields.io/badge/ASE_București-SGBD_Project-003087?style=for-the-badge)](https://www.ase.ro/)

</div>

---

## 📖 Overview

This project implements **advanced Oracle PL/SQL business logic** for an Art Gallery management system. The database tracks artists, artworks, exhibitions, clients, and sales — then automates pricing rules, data validation, reporting, and gallery operations through programmatic database objects.

The codebase covers **4 major chapters** of Oracle PL/SQL: control structures, cursors, exception handling, and stored subprograms (functions, procedures, triggers, and packages).

> **Domain:** An art gallery collaborates with international artists (RO, IT, JP, FR, ES, DE) across 6 exhibitions, managing 24+ artworks and client purchase history. Every pricing decision, sale validation, and report is handled at the database layer.

---

## ✨ Key Features

| Category | Feature | Description |
|---|---|---|
| 🔁 **Control Structures** | Price adjustment engine | Compares `pret_final` vs `pret_estimativ`; applies +5% if below 90%, -3% if above 120% |
| 🔁 **Control Structures** | Client categorization | VIP / NORMAL classification based on total spend threshold (8,000 RON) |
| 🔁 **Control Structures** | Exhibition status check | Compares `SYSDATE` with open/close dates → `IN DESFASURARE` or `INCHEIATA` |
| 🔁 **Control Structures** | Technique-based pricing | ULEI +15%, ACRILIC +10%, others +5% — applied via FOR loop over artist's works |
| 🖱️ **Cursors** | Implicit cursors | `SQL%FOUND`, `SQL%ROWCOUNT` for bulk UPDATE/DELETE with feedback |
| 🖱️ **Cursors** | Explicit cursors | Parameterized cursors iterating over exhibition artworks, artist portfolios, client purchases |
| 🖱️ **Cursors** | Nested cursors | `c_artisti` → `c_lucrari(p_artist)` double loop for full portfolio report across all 10 artists |
| 🖱️ **Cursors** | Client tier reporting | BRONZE / SILVER / GOLD tier from aggregated cursor totals |
| ⚠️ **Exceptions** | System exceptions | `NO_DATA_FOUND`, `TOO_MANY_ROWS` handled for artist/client/exhibition lookups |
| ⚠️ **Exceptions** | User-defined exceptions | `ex_fara_vanzari`, `ex_fara_lucrari`, `ex_fara_achizitii` — raised explicitly with `RAISE` |
| ⚠️ **Exceptions** | Artist classification | MIC / MEDIU / IMPORTANT based on total estimated portfolio value |
| ⚙️ **Functions** | `fisa_artist` | Returns artist name, country, artwork count, and total estimated value as VARCHAR2 |
| ⚙️ **Functions** | `categorie_client` | NORMAL / VIP / PREMIUM based on total purchases |
| ⚙️ **Functions** | `status_expozitie` | Returns live exhibition status using `SYSDATE` comparison |
| ⚙️ **Functions** | `lucrare_max_artist` | Returns title of highest-priced artwork per artist |
| ⚙️ **Functions** | `status_client_complet` | Full client summary: name, purchase count, total, category |
| ⚙️ **Procedures** | `proc_raport_artist` | Full artist report with cursor + calls `lucrare_max_artist` |
| ⚙️ **Procedures** | `proc_actualizeaza_expozitie` | Prefixes all exhibition locations with `SECTOR-`, skips already-prefixed rows |
| ⚙️ **Procedures** | `proc_raport_client` | Full purchase history + top artwork via `lucrare_scumpa_client` |
| ⚙️ **Procedures** | `proc_dubleaza_lucrari_artist` | Doubles prices, stores titles in an **indexed-by table collection**, prints elements |
| 🔔 **Triggers** | `trg_an_realizare` | Blocks INSERT/UPDATE if artwork year > current year (`RAISE_APPLICATION_ERROR -20001`) |
| 🔔 **Triggers** | `trg_pret_pozitiv` | Blocks INSERT if sale price ≤ 0 (`RAISE_APPLICATION_ERROR -20002`) |
| 🔔 **Triggers** | `trg_mesaj_stergere` | AFTER DELETE on artists — logs artist ID to DBMS_OUTPUT |
| 🔔 **Triggers** | `trg_data_vanzare` | Auto-sets `data_vanzare := SYSDATE` when NULL on insert |
| 🔔 **Triggers** | `trg_limita_pret` | Caps estimated price at 100,000 (`RAISE_APPLICATION_ERROR -20003`) |
| 🔔 **Triggers** | `trg_tehnica_upper` | Auto-normalizes technique to UPPER on every INSERT/UPDATE |
| 📦 **Packages** | `PAC_ARTISTI_ADV` | Overloaded `cauta_artist` (by ID → name, by name → ID) + indexed collection display |
| 📦 **Packages** | `PAC_FINANCIAR` | Package-level variable `g_comision_galerie`; profitability check against dynamic commission |
| 📦 **Packages** | `PAC_LOGISTICA_EXPO` | `SAVEPOINT`/`ROLLBACK TO` transaction control for secure artwork migration between exhibitions |
| 📦 **Packages** | `PAC_SISTEM_AUDIT` | JSON-formatted client report generator + `NOT EXISTS` filter for artists with zero artworks |

---

## 🗄️ Database Schema

The system is built on **5 core tables** with referential integrity enforced at the schema level:

```
ARTISTI_PRJ          LUCRARI_ARTA_PRJ         EXPOZITII_PRJ
─────────────        ─────────────────        ─────────────────
id_artist (PK)  ──►  id_lucrare (PK)          id_expozitie (PK)
nume                  titlu                    nume
tara_origine          an_realizare             data_deschidere
data_nasterii         tehnica                  data_inchidere
biografie             pret_estimativ           locatie
                      id_artist (FK)
                           │
                           ▼
                  LUCRARI_EXPOZITII_PRJ        VANZARI_PRJ
                  ─────────────────────        ───────────────
                  id_lucrare (PFK)        ◄──  id_lucrare (FK)
                  id_expozitie (PFK)           id_vanzare (PK)
                  data_expusa                  data_vanzare
                  loc_in_expozitie             pret_final
                                               id_client (FK)

                                         CLIENTI_PRJ
                                         ─────────────
                                         id_client (PK)
                                         nume
                                         email
                                         telefon
                                         adresa
```

**Sample data includes:** 10 international artists (Andrei Popescu, Maria Ionescu, Luca Bianchi, Sophie Dubois, Emily Johnson, Kenji Tanaka, Carlos Martinez, Anna Muller, Elena Petrescu, Oliver Smith), 24 artworks across techniques (Ulei pe panzã, Acrilic, Mixed media, Digital print, Instalatie, etc.), 6 exhibitions (Culori Urbane, Abstract si Forme, Portrete Contemporane, Lumi Imaginare, Minimalism si Linie, Peisaje si Natura).

---

## 🏗️ Repository Structure

```
Oracle-PLSQL-Advanced-Business-Logic/
│
├── Advanced_Logic.sql              # Parts 1–3: Control structures, cursors, exceptions
│   ├── Part 1 – Control Structures (6 blocks)
│   │   ├── Price adjustment with IF/ELSIF + UPDATE + RETURNING
│   │   ├── Client VIP/NORMAL classifier
│   │   ├── Exhibition status via SYSDATE BETWEEN
│   │   ├── Technique-based price update (FOR loop over ID range)
│   │   ├── Extended client report with MAX subquery
│   │   └── Bulk DELETE with ADD_MONTHS(-12) + SQL%ROWCOUNT
│   │
│   ├── Part 2 – Cursors (9 blocks)
│   │   ├── Implicit: UPDATE/DELETE + SQL%FOUND / SQL%ROWCOUNT
│   │   ├── Explicit: parameterized + OPEN/FETCH/CLOSE loops
│   │   └── Nested: c_artisti ──► c_lucrari(p_artist)
│   │
│   └── Part 3 – Exception Handling (7 blocks)
│       ├── NO_DATA_FOUND, TOO_MANY_ROWS
│       └── User-defined: ex_fara_vanzari, ex_fara_lucrari, ex_fara_achizitii
│
├── Analytical_Queries.sql          # Part 4: Functions, procedures, triggers, packages
│   ├── Functions (5): fisa_artist, categorie_client, status_expozitie,
│   │                  lucrare_max_artist, status_client_complet
│   ├── Procedures (4): proc_raport_artist, proc_actualizeaza_expozitie,
│   │                   proc_raport_client, proc_dubleaza_lucrari_artist
│   ├── Triggers (6): trg_an_realizare, trg_pret_pozitiv, trg_mesaj_stergere,
│   │                 trg_data_vanzare, trg_limita_pret, trg_tehnica_upper
│   └── Packages (4): PAC_ARTISTI_ADV, PAC_FINANCIAR,
│                     PAC_LOGISTICA_EXPO, PAC_SISTEM_AUDIT
│
└── Proiect.pdf                     # Academic documentation with ERD and output screenshots
```

---

## 🧠 What I Learned

- **Procedural Oracle PL/SQL** — writing `DECLARE/BEGIN/EXCEPTION/END` blocks from scratch, understanding anonymous vs. named blocks
- **Cursor mechanics** — difference between implicit (`SQL%ROWCOUNT`) and explicit (`OPEN/FETCH/CLOSE`), parameterized cursors, cursor attributes (`%FOUND`, `%NOTFOUND`, `%ROWCOUNT`)
- **Exception architecture** — when to use system exceptions vs. user-defined ones, the importance of `WHEN OTHERS THEN` as a safety net
- **Modular database design** — how functions, procedures, and packages reduce code duplication and improve maintainability
- **Trigger types and timing** — BEFORE vs. AFTER, row-level vs. statement-level, `:NEW` / `:OLD` pseudo-records
- **Transaction control** — `SAVEPOINT`, `ROLLBACK TO`, `COMMIT` in package procedures to ensure atomicity
- **Collections** — indexed-by tables (`TABLE OF ... INDEX BY PLS_INTEGER`) for in-memory data buffering within procedures
- **Package-level state** — using package variables (`g_comision_galerie`) to maintain session-scoped configuration
- **Function overloading** — same function name, different parameter signatures (`cauta_artist(NUMBER)` vs `cauta_artist(VARCHAR2)`)

---

## 🔧 Context

Built as the second part of the **Advanced SGBD** course project at **ASE București, Facultatea de Cibernetică, specializarea Informatică Economică** (Year 2). The first part covered schema design and DDL/DML; this part focuses entirely on programmatic database logic.

Tools: **Oracle SQL Developer**, **Oracle Database 19c**, **OCI (Oracle Cloud Infrastructure)** sandbox environment.

---

## 👤 Author

<div align="center">

**Andronescu Mihai-Alexandru**
*Student Anul 2 → 3 | Informatică Economică | ASE București*

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/andronescumihai)
[![GitHub](https://img.shields.io/badge/GitHub-Profile-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/andronescumihai)

</div>
