
-- Einfügen von Zutaten
INSERT INTO zutaten (name, preis, is_Predefined) VALUES ('Extra Tomaten', 2.0, true);
INSERT INTO zutaten (name, preis, is_Predefined) VALUES ('Extra Käse', 2.5, true);
INSERT INTO zutaten (name, preis, is_Predefined) VALUES ('Extra Zwiebeln', 1.5, true);
INSERT INTO zutaten (name, preis, is_Predefined) VALUES ('Oliven', 3.5, true);


-- Einfügen von Getränken
INSERT INTO getraenke (name, preis, image_url, is_Predefined) VALUES ('Fanta Orange 0,33l', 3.5, 'Fanta_Orange.png', true);
INSERT INTO getraenke (name, preis, image_url, is_Predefined) VALUES ('Coca-Cola 0,33l', 3.5, 'Coca_Cola.png', true);
INSERT INTO getraenke (name, preis, image_url, is_Predefined) VALUES ('Wolfra Schorle Apfel 0,33l', 3.5, 'Wolfra_Schorle_Apfel.png', true);
INSERT INTO getraenke (name, preis, image_url, is_Predefined) VALUES ('Red Bull Energy Drink 0,25l', 3.7, 'Red_Bull.png', true);


INSERT INTO pizza (name, beschreibung, preis, image_Url, is_Predefined) VALUES ('Pizza Funghi', 'Mit frischen Champignons. Wird mit Tomatensauce und Käsemix zubereitet.', 10.5, 'Pizza_Funghi.jpeg', true);
INSERT INTO pizza (name, beschreibung, preis, image_Url, is_Predefined) VALUES ('Pizza Margherita', 'Klassische Pizza mit Tomaten Sauce und Käsemix.', 8.5, 'Pizza_Margherita.jpeg', true);
INSERT INTO pizza (name, beschreibung, preis, image_Url, is_Predefined) VALUES ('Pizza Tonno', 'Pizza mit Thunfisch, Zwiebeln und Tomatensauce.', 10.5, 'Pizza_Tonno.jpeg', true);
INSERT INTO pizza (name, beschreibung, preis, image_Url, is_Predefined) VALUES ('Pizza Salami', 'Pizza mit scharfer Salami, Tomatensauce und Käsemix.', 11.0, 'Pizza_Salami.jpeg', true);
INSERT INTO pizza (name, beschreibung, preis, image_Url, is_Predefined) VALUES ('Pizza Hawaii', 'Pizza mit Schinken, Ananas und Tomatensauce.', 11.0, 'Pizza_Hawaii.jpeg', true);