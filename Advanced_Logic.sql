--1
SET SERVEROUTPUT ON; 
 
DECLARE 
    v_id_vanzare  VANZARI_PRJ.id_vanzare%TYPE := &id_vanzare; 
 
    v_id_lucrare  VANZARI_PRJ.id_lucrare%TYPE; 
    v_pret_final  VANZARI_PRJ.pret_final%TYPE; 
 
    v_titlu       LUCRARI_ARTA_PRJ.titlu%TYPE; 
    v_pret_est    LUCRARI_ARTA_PRJ.pret_estimativ%TYPE; 
 
    v_nou_final   NUMBER; 
    v_status      VARCHAR2(20); 
BEGIN 
    SELECT id_lucrare, pret_final 
    INTO v_id_lucrare, v_pret_final 
    FROM VANZARI_PRJ 
    WHERE id_vanzare = v_id_vanzare; 
 
    SELECT titlu, pret_estimativ 
    INTO v_titlu, v_pret_est 
    FROM LUCRARI_ARTA_PRJ 
    WHERE id_lucrare = v_id_lucrare; 
 
    v_nou_final := v_pret_final; 
    v_status := 'OK'; 
 
    IF v_pret_final < 0.9 * v_pret_est THEN 
        v_status := 'DISCOUNT'; 
        v_nou_final := ROUND(v_pret_final * 1.05, 2); 
    ELSIF v_pret_final > 1.2 * v_pret_est THEN 
        v_status := 'PREMIUM'; 
        v_nou_final := ROUND(v_pret_final * 0.97, 2); 
    END IF; 
 
    UPDATE VANZARI_PRJ 
    SET pret_final = v_nou_final 
    WHERE id_vanzare = v_id_vanzare 
    RETURNING pret_final INTO v_nou_final; 
 
    DBMS_OUTPUT.PUT_LINE('ID_VANZARE | TITLU | ESTIMAT | FINAL_OLD | FINAL_NEW | STATUS'); 
    DBMS_OUTPUT.PUT_LINE( 
        v_id_vanzare || ' | ' || v_titlu || ' | ' || v_pret_est || ' | ' || 
        v_pret_final || ' | ' || v_nou_final || ' | ' || v_status 
    ); 
 
    COMMIT; 
END; 
/ 
--2
SET SERVEROUTPUT ON;

DECLARE
    v_id_client   CLIENTI_PRJ.id_client%TYPE := &id_client;
    v_nume        CLIENTI_PRJ.nume%TYPE;
    v_email       CLIENTI_PRJ.email%TYPE;
    v_nr_vanzari  NUMBER;
    v_total       NUMBER;
    v_categorie   VARCHAR2(20);
BEGIN
    SELECT nume, email
    INTO v_nume, v_email
    FROM CLIENTI_PRJ
    WHERE id_client = v_id_client;

    SELECT COUNT(*), NVL(SUM(pret_final), 0)
    INTO v_nr_vanzari, v_total
    FROM VANZARI_PRJ
    WHERE id_client = v_id_client;

    IF v_total >= 8000 THEN
        v_categorie := 'VIP';
    ELSE
        v_categorie := 'NORMAL';
    END IF;

    DBMS_OUTPUT.PUT_LINE('ID_CLIENT | NUME | EMAIL | NR_VANZARI | TOTAL | CATEGORIE');
    DBMS_OUTPUT.PUT_LINE(v_id_client || ' | ' || v_nume || ' | ' || v_email || ' | ' ||
                         v_nr_vanzari || ' | ' || v_total || ' | ' || v_categorie);
END;
/
--3
SET SERVEROUTPUT ON;

DECLARE
    v_id_expozitie  EXPOZITII_PRJ.id_expozitie%TYPE := &id_expozitie;
    v_nume          EXPOZITII_PRJ.nume%TYPE;
    v_locatie       EXPOZITII_PRJ.locatie%TYPE;
    v_data_desch    EXPOZITII_PRJ.data_deschidere%TYPE;
    v_data_inch     EXPOZITII_PRJ.data_inchidere%TYPE;
    v_nr_lucrari    NUMBER;
    v_status        VARCHAR2(20);
BEGIN
    SELECT nume, locatie, data_deschidere, data_inchidere
    INTO v_nume, v_locatie, v_data_desch, v_data_inch
    FROM EXPOZITII_PRJ
    WHERE id_expozitie = v_id_expozitie;

    SELECT COUNT(*)
    INTO v_nr_lucrari
    FROM LUCRARI_EXPOZITII_PRJ
    WHERE id_expozitie = v_id_expozitie;

    IF SYSDATE BETWEEN v_data_desch AND v_data_inch THEN
        v_status := 'IN DESFASURARE';
    ELSE
        v_status := 'INCHEIATA';
    END IF;

    DBMS_OUTPUT.PUT_LINE('ID_EXPOZITIE | NUME | LOCATIE | DATA_DESCH | DATA_INCH | NR_LUCRARI | STATUS');
    DBMS_OUTPUT.PUT_LINE(v_id_expozitie || ' | ' || v_nume || ' | ' || v_locatie || ' | ' ||
                         TO_CHAR(v_data_desch, 'DD-MM-YYYY') || ' | ' ||
                         TO_CHAR(v_data_inch, 'DD-MM-YYYY') || ' | ' ||
                         v_nr_lucrari || ' | ' || v_status);
END;
/ 
--4
SET SERVEROUTPUT ON; 
 
DECLARE 
    v_id_artist  LUCRARI_ARTA_PRJ.id_artist%TYPE := &id_artist; 
    v_min_id     NUMBER; 
    v_max_id     NUMBER; 
 
    v_exista     NUMBER; 
    v_tehnica    LUCRARI_ARTA_PRJ.tehnica%TYPE; 
    v_titlu      LUCRARI_ARTA_PRJ.titlu%TYPE; 
    v_old        NUMBER; 
    v_new        NUMBER; 
 
    v_modificate NUMBER := 0; 
BEGIN 
     
    SELECT MIN(id_lucrare), MAX(id_lucrare) 
    INTO v_min_id, v_max_id 
    FROM LUCRARI_ARTA_PRJ 
    WHERE id_artist = v_id_artist; 
 
    DBMS_OUTPUT.PUT_LINE('ID | TITLU | TEHNICA | OLD | NEW'); 
 
    FOR v_id IN v_min_id..v_max_id LOOP 
        SELECT COUNT(*) 
        INTO v_exista 
        FROM LUCRARI_ARTA_PRJ 
        WHERE id_lucrare = v_id 
          AND id_artist = v_id_artist; 
 
        IF v_exista = 1 THEN 
            SELECT titlu, tehnica, pret_estimativ 
            INTO v_titlu, v_tehnica, v_old 
            FROM LUCRARI_ARTA_PRJ 
            WHERE id_lucrare = v_id; 
 
            v_new := v_old; 
 
            IF UPPER(v_tehnica) = 'ULEI' THEN 
                v_new := ROUND(v_old * 1.15, 2); 
            ELSIF UPPER(v_tehnica) = 'ACRILIC' THEN 
                v_new := ROUND(v_old * 1.10, 2); 
            ELSE 
                v_new := ROUND(v_old * 1.05, 2); 
            END IF; 
 
            UPDATE LUCRARI_ARTA_PRJ 
            SET pret_estimativ = v_new 
            WHERE id_lucrare = v_id; 
 
            v_modificate := v_modificate + 1; 
 
            DBMS_OUTPUT.PUT_LINE(v_id || ' | ' || v_titlu || ' | ' || v_tehnica || ' | ' || v_old || ' | ' || v_new); 
        END IF; 
    END LOOP; 
 
    DBMS_OUTPUT.PUT_LINE('TOTAL MODIFICATE: ' || v_modificate); 
 
    COMMIT; 
END; 
/ 
--5
SET SERVEROUTPUT ON; 
 
DECLARE 
    v_id_client  CLIENTI_PRJ.id_client%TYPE := &id_client; 
    v_nume       CLIENTI_PRJ.nume%TYPE; 
 
    v_nr         NUMBER; 
    v_total      NUMBER; 
 
    v_id_v_max   VANZARI_PRJ.id_vanzare%TYPE; 
    v_p_max      VANZARI_PRJ.pret_final%TYPE; 
    v_id_luc     VANZARI_PRJ.id_lucrare%TYPE; 
 
    v_titlu      LUCRARI_ARTA_PRJ.titlu%TYPE; 
BEGIN 
    SELECT nume INTO v_nume 
    FROM CLIENTI_PRJ 
    WHERE id_client = v_id_client; 
 
    SELECT COUNT(*), NVL(SUM(pret_final),0) 
    INTO v_nr, v_total 
    FROM VANZARI_PRJ 
    WHERE id_client = v_id_client; 
 
    DBMS_OUTPUT.PUT_LINE('CLIENT | NR_VANZARI | TOTAL | CATEGORIE'); 
    IF v_total >= 8000 THEN 
        DBMS_OUTPUT.PUT_LINE(v_nume || ' | ' || v_nr || ' | ' || v_total || ' | VIP'); 
    ELSE 
        DBMS_OUTPUT.PUT_LINE(v_nume || ' | ' || v_nr || ' | ' || v_total || ' | NORMAL'); 
    END IF; 
 
    IF v_nr > 0 THEN 
        SELECT id_vanzare, pret_final, id_lucrare 
        INTO v_id_v_max, v_p_max, v_id_luc 
        FROM VANZARI_PRJ 
        WHERE id_client = v_id_client 
          AND pret_final = (SELECT MAX(pret_final) FROM VANZARI_PRJ WHERE id_client = v_id_client) 
          FETCH FIRST 1 ROW ONLY; 
 
        SELECT titlu INTO v_titlu 
        FROM LUCRARI_ARTA_PRJ 
        WHERE id_lucrare = v_id_luc; 
 
        DBMS_OUTPUT.PUT_LINE('TOP: vanzare ' || v_id_v_max || ' | ' || v_p_max || ' | lucrare: ' || v_titlu); 
    ELSE 
        DBMS_OUTPUT.PUT_LINE('TOP: clientul nu are achizitii.'); 
    END IF; 
END; 
/ 
--6
SET SERVEROUTPUT ON; 
 
DECLARE 
    v_id_expo  LUCRARI_EXPOZITII_PRJ.id_expozitie%TYPE := &id_expozitie; 
    v_sterse   NUMBER; 
BEGIN 
    DELETE FROM LUCRARI_EXPOZITII_PRJ 
    WHERE id_expozitie = v_id_expo 
      AND data_expusa < ADD_MONTHS(SYSDATE, -12); 
 
    v_sterse := SQL%ROWCOUNT; 
 
    DBMS_OUTPUT.PUT_LINE('Expozitie ' || v_id_expo || ' | Randuri sterse: ' || v_sterse); 
 
    COMMIT; 
END; 
--7
SET SERVEROUTPUT ON;

DECLARE
    v_id_artist LUCRARI_ARTA_PRJ.id_artist%TYPE := &id_artist;
BEGIN
    UPDATE LUCRARI_ARTA_PRJ
    SET pret_estimativ = pret_estimativ * 1.10
    WHERE id_artist = v_id_artist
      AND an_realizare > 2020;

    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('S-au modificat ' || SQL%ROWCOUNT || ' lucrari.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nu exista lucrari care sa respecte conditia.');
    END IF;

    COMMIT;
END;
/
--8
SET SERVEROUTPUT ON;

DECLARE
    v_id_artist LUCRARI_ARTA_PRJ.id_artist%TYPE := &id_artist;
BEGIN
    UPDATE LUCRARI_ARTA_PRJ
    SET pret_estimativ = ROUND(pret_estimativ * 1.10, 2)
    WHERE id_artist = v_id_artist
      AND an_realizare < 2020;

    DBMS_OUTPUT.PUT_LINE('ID_ARTIST | NR_LUCRARI_MODIFICATE');
    DBMS_OUTPUT.PUT_LINE(v_id_artist || ' | ' || SQL%ROWCOUNT);

    COMMIT;
END;
/

--9
SET SERVEROUTPUT ON;

DECLARE
    v_id_client VANZARI_PRJ.id_client%TYPE := &id_client;
BEGIN
    UPDATE VANZARI_PRJ
    SET pret_final = ROUND(pret_final * 1.05, 2)
    WHERE id_client = v_id_client
      AND pret_final < 3000;

    DBMS_OUTPUT.PUT_LINE('ID_CLIENT | NR_VANZARI_MODIFICATE');
    DBMS_OUTPUT.PUT_LINE(v_id_client || ' | ' || SQL%ROWCOUNT);

    COMMIT;
END;
/
--10
SET SERVEROUTPUT ON;

DECLARE
    v_id_expozitie LUCRARI_EXPOZITII_PRJ.id_expozitie%TYPE := &id_expozitie;
BEGIN
    UPDATE LUCRARI_EXPOZITII_PRJ
    SET loc_in_expozitie = 'SECTOR-' || loc_in_expozitie
    WHERE id_expozitie = v_id_expozitie
      AND loc_in_expozitie NOT LIKE 'SECTOR-%';

    DBMS_OUTPUT.PUT_LINE('ID_EXPOZITIE | NR_INREGISTRARI_MODIFICATE');
    DBMS_OUTPUT.PUT_LINE(v_id_expozitie || ' | ' || SQL%ROWCOUNT);

    COMMIT;
END;
--11
SET SERVEROUTPUT ON;

DECLARE
    v_id_expozitie EXPOZITII_PRJ.id_expozitie%TYPE := &id_expozitie;

    CURSOR c_lucrari IS
        SELECT l.id_lucrare, l.titlu, l.pret_estimativ, le.loc_in_expozitie
        FROM LUCRARI_ARTA_PRJ l, LUCRARI_EXPOZITII_PRJ le
        WHERE l.id_lucrare = le.id_lucrare
          AND le.id_expozitie = v_id_expozitie
        ORDER BY l.id_lucrare;

    v_id_lucrare LUCRARI_ARTA_PRJ.id_lucrare%TYPE;
    v_titlu LUCRARI_ARTA_PRJ.titlu%TYPE;
    v_pret LUCRARI_ARTA_PRJ.pret_estimativ%TYPE;
    v_loc LUCRARI_EXPOZITII_PRJ.loc_in_expozitie%TYPE;
BEGIN
    OPEN c_lucrari;

    DBMS_OUTPUT.PUT_LINE('ID_LUCRARE | TITLU | PRET_ESTIMATIV | LOC_IN_EXPOZITIE');

    LOOP
        FETCH c_lucrari INTO v_id_lucrare, v_titlu, v_pret, v_loc;
        EXIT WHEN c_lucrari%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_id_lucrare || ' | ' || v_titlu || ' | ' || v_pret || ' | ' || v_loc);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('TOTAL_LUCRARI | ' || c_lucrari%ROWCOUNT);

    CLOSE c_lucrari;
END;
/
--12
SET SERVEROUTPUT ON;

DECLARE
    v_id_artist ARTISTI_PRJ.id_artist%TYPE := &id_artist;

    CURSOR c_lucrari IS
        SELECT id_lucrare, titlu, an_realizare, pret_estimativ
        FROM LUCRARI_ARTA_PRJ
        WHERE id_artist = v_id_artist
          AND pret_estimativ > (
                SELECT AVG(pret_estimativ)
                FROM LUCRARI_ARTA_PRJ
                WHERE id_artist = v_id_artist
          )
        ORDER BY pret_estimativ DESC;

    v_id_lucrare LUCRARI_ARTA_PRJ.id_lucrare%TYPE;
    v_titlu LUCRARI_ARTA_PRJ.titlu%TYPE;
    v_an LUCRARI_ARTA_PRJ.an_realizare%TYPE;
    v_pret LUCRARI_ARTA_PRJ.pret_estimativ%TYPE;
BEGIN
    OPEN c_lucrari;

    DBMS_OUTPUT.PUT_LINE('ID_LUCRARE | TITLU | AN_REALIZARE | PRET_ESTIMATIV');

    LOOP
        FETCH c_lucrari INTO v_id_lucrare, v_titlu, v_an, v_pret;
        EXIT WHEN c_lucrari%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_id_lucrare || ' | ' || v_titlu || ' | ' || v_an || ' | ' || v_pret);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('TOTAL_LUCRARI | ' || c_lucrari%ROWCOUNT);

    CLOSE c_lucrari;
END;
/
--13
SET SERVEROUTPUT ON;

DECLARE
    v_id_client CLIENTI_PRJ.id_client%TYPE := &id_client;

    CURSOR c_vanzari IS
        SELECT v.id_vanzare, l.titlu, v.data_vanzare, v.pret_final
        FROM VANZARI_PRJ v, LUCRARI_ARTA_PRJ l
        WHERE v.id_lucrare = l.id_lucrare
          AND v.id_client = v_id_client
        ORDER BY v.data_vanzare;

    v_id_vanzare VANZARI_PRJ.id_vanzare%TYPE;
    v_titlu LUCRARI_ARTA_PRJ.titlu%TYPE;
    v_data VANZARI_PRJ.data_vanzare%TYPE;
    v_pret VANZARI_PRJ.pret_final%TYPE;
    v_total NUMBER := 0;
BEGIN
    OPEN c_vanzari;

    DBMS_OUTPUT.PUT_LINE('ID_VANZARE | TITLU | DATA_VANZARE | PRET_FINAL');

    LOOP
        FETCH c_vanzari INTO v_id_vanzare, v_titlu, v_data, v_pret;
        EXIT WHEN c_vanzari%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_id_vanzare || ' | ' || v_titlu || ' | ' ||
                             TO_CHAR(v_data,'DD-MM-YYYY') || ' | ' || v_pret);

        v_total := v_total + v_pret;
    END LOOP;

    CLOSE c_vanzari;

    DBMS_OUTPUT.PUT_LINE('TOTAL_CUMPARATURI | ' || v_total);

    IF v_total < 5000 THEN
        DBMS_OUTPUT.PUT_LINE('CATEGORIE | BRONZE');
    ELSIF v_total <= 10000 THEN
        DBMS_OUTPUT.PUT_LINE('CATEGORIE | SILVER');
    ELSE
        DBMS_OUTPUT.PUT_LINE('CATEGORIE | GOLD');
    END IF;
END;
/
--14
SET SERVEROUTPUT ON;

DECLARE
    CURSOR c_artisti IS
        SELECT id_artist, nume
        FROM ARTISTI_PRJ
        ORDER BY id_artist;

    CURSOR c_lucrari(p_artist NUMBER) IS
        SELECT id_lucrare, titlu, pret_estimativ
        FROM LUCRARI_ARTA_PRJ
        WHERE id_artist = p_artist
        ORDER BY id_lucrare;

    v_id_artist ARTISTI_PRJ.id_artist%TYPE;
    v_nume_artist ARTISTI_PRJ.nume%TYPE;

    v_id_lucrare LUCRARI_ARTA_PRJ.id_lucrare%TYPE;
    v_titlu LUCRARI_ARTA_PRJ.titlu%TYPE;
    v_pret LUCRARI_ARTA_PRJ.pret_estimativ%TYPE;

    v_total NUMBER;
BEGIN
    OPEN c_artisti;

    LOOP
        FETCH c_artisti INTO v_id_artist, v_nume_artist;
        EXIT WHEN c_artisti%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ARTIST | ' || v_id_artist || ' | ' || v_nume_artist);
        DBMS_OUTPUT.PUT_LINE('ID_LUCRARE | TITLU | PRET_ESTIMATIV');

        v_total := 0;

        OPEN c_lucrari(v_id_artist);

        LOOP
            FETCH c_lucrari INTO v_id_lucrare, v_titlu, v_pret;
            EXIT WHEN c_lucrari%NOTFOUND;

            DBMS_OUTPUT.PUT_LINE(v_id_lucrare || ' | ' || v_titlu || ' | ' || v_pret);
            v_total := v_total + v_pret;
        END LOOP;

        CLOSE c_lucrari;

        DBMS_OUTPUT.PUT_LINE('TOTAL_ARTIST | ' || v_total);
        DBMS_OUTPUT.PUT_LINE('-----');
    END LOOP;

    CLOSE c_artisti;
END;
/
--15
SET SERVEROUTPUT ON;

DECLARE
    CURSOR c_expozitii IS
        SELECT id_expozitie, nume
        FROM EXPOZITII_PRJ
        ORDER BY id_expozitie;

    CURSOR c_lucrari(p_expozitie NUMBER) IS
        SELECT l.id_lucrare, l.titlu, l.pret_estimativ
        FROM LUCRARI_ARTA_PRJ l, LUCRARI_EXPOZITII_PRJ le
        WHERE l.id_lucrare = le.id_lucrare
          AND le.id_expozitie = p_expozitie
        ORDER BY l.id_lucrare;

    v_id_expozitie EXPOZITII_PRJ.id_expozitie%TYPE;
    v_nume_expozitie EXPOZITII_PRJ.nume%TYPE;

    v_id_lucrare LUCRARI_ARTA_PRJ.id_lucrare%TYPE;
    v_titlu LUCRARI_ARTA_PRJ.titlu%TYPE;
    v_pret LUCRARI_ARTA_PRJ.pret_estimativ%TYPE;

    v_total NUMBER;
BEGIN
    OPEN c_expozitii;

    LOOP
        FETCH c_expozitii INTO v_id_expozitie, v_nume_expozitie;
        EXIT WHEN c_expozitii%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('EXPOZITIE | ' || v_id_expozitie || ' | ' || v_nume_expozitie);
        DBMS_OUTPUT.PUT_LINE('ID_LUCRARE | TITLU | PRET_ESTIMATIV');

        v_total := 0;

        OPEN c_lucrari(v_id_expozitie);

        LOOP
            FETCH c_lucrari INTO v_id_lucrare, v_titlu, v_pret;
            EXIT WHEN c_lucrari%NOTFOUND;

            DBMS_OUTPUT.PUT_LINE(v_id_lucrare || ' | ' || v_titlu || ' | ' || v_pret);
            v_total := v_total + v_pret;
        END LOOP;

        CLOSE c_lucrari;

        DBMS_OUTPUT.PUT_LINE('TOTAL_EXPOZITIE | ' || v_total);
        DBMS_OUTPUT.PUT_LINE('----');
    END LOOP;

    CLOSE c_expozitii;
END;
/
--16
