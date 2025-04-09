-- Création de la base de données e-commerce
-- Script PostgreSQL complet avec tables et données fictives

-- Suppression des tables si elles existent déjà
DROP TABLE IF EXISTS wishlist;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS product_categories;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS coupons;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS payment_methods;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS users;

-- Table des utilisateurs
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Table des adresses
CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    address_line1 VARCHAR(100) NOT NULL,
    address_line2 VARCHAR(100),
    city VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des méthodes de paiement
CREATE TABLE payment_methods (
    payment_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    payment_type VARCHAR(50) NOT NULL,
    card_last_digits VARCHAR(4),
    expiry_date VARCHAR(7),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des catégories
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    parent_category_id INTEGER REFERENCES categories(category_id),
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des produits
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    discount_percentage DECIMAL(5, 2) DEFAULT 0,
    sku VARCHAR(50) UNIQUE,
    image_url VARCHAR(255),
    weight DECIMAL(8, 2),
    dimensions VARCHAR(50),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table d'inventaire
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table de jointure produits-catégories
CREATE TABLE product_categories (
    product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(category_id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, category_id)
);

-- Table des commandes
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    address_id INTEGER NOT NULL REFERENCES addresses(address_id),
    payment_id INTEGER REFERENCES payment_methods(payment_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    shipping_cost DECIMAL(6, 2) NOT NULL,
    tax DECIMAL(6, 2) NOT NULL,
    coupon_code VARCHAR(20),
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    tracking_number VARCHAR(50)
);

-- Table des éléments de commande
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    price_per_unit DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL
);

-- Table des avis
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des codes promo
CREATE TABLE coupons (
    coupon_id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    discount_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL,
    min_purchase_amount DECIMAL(10, 2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    usage_limit INTEGER,
    usage_count INTEGER DEFAULT 0
);

-- Table des listes de souhait
CREATE TABLE wishlist (
    wishlist_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, product_id)
);

-- Insertion des données fictives

-- Utilisateurs
INSERT INTO users (email, password, first_name, last_name, phone, is_admin) VALUES
('admin@example.com', 'hashed_password123', 'Admin', 'User', '+33123456789', TRUE),
('jean.dupont@example.com', 'hashed_password123', 'Jean', 'Dupont', '+33612345678', FALSE),
('marie.martin@example.com', 'hashed_password456', 'Marie', 'Martin', '+33623456789', FALSE),
('pierre.durand@example.com', 'hashed_password789', 'Pierre', 'Durand', '+33634567890', FALSE),
('sophie.petit@example.com', 'hashed_password101', 'Sophie', 'Petit', '+33645678901', FALSE),
('lucas.bernard@example.com', 'hashed_password202', 'Lucas', 'Bernard', '+33656789012', FALSE);

-- Adresses
INSERT INTO addresses (user_id, address_line1, address_line2, city, postal_code, country, is_default) VALUES
(1, '123 Rue de la Paix', 'Apt 4B', 'Paris', '75001', 'France', TRUE),
(2, '45 Avenue des Champs-Élysées', NULL, 'Paris', '75008', 'France', TRUE),
(2, '8 Rue du Commerce', 'Bât C', 'Lyon', '69002', 'France', FALSE),
(3, '12 Boulevard Saint-Michel', NULL, 'Paris', '75005', 'France', TRUE),
(4, '67 Rue de la République', '2ème étage', 'Marseille', '13001', 'France', TRUE),
(5, '29 Avenue Jean Jaurès', NULL, 'Toulouse', '31000', 'France', TRUE);

-- Méthodes de paiement
INSERT INTO payment_methods (user_id, payment_type, card_last_digits, expiry_date, is_default) VALUES
(1, 'VISA', '1234', '12/2025', TRUE),
(2, 'MASTERCARD', '5678', '09/2024', TRUE),
(2, 'PAYPAL', NULL, NULL, FALSE),
(3, 'VISA', '9012', '03/2026', TRUE),
(4, 'AMERICAN EXPRESS', '3456', '07/2025', TRUE),
(5, 'MASTERCARD', '7890', '11/2024', TRUE);

-- Catégories
INSERT INTO categories (name, description, parent_category_id, image_url) VALUES
('Électronique', 'Tous les appareils électroniques', NULL, 'electronics.jpg'),
('Smartphones', 'Téléphones mobiles et accessoires', 1, 'smartphones.jpg'),
('Ordinateurs', 'Ordinateurs portables et de bureau', 1, 'computers.jpg'),
('Vêtements', 'Vêtements pour hommes, femmes et enfants', NULL, 'clothing.jpg'),
('Hommes', 'Vêtements pour hommes', 4, 'men.jpg'),
('Femmes', 'Vêtements pour femmes', 4, 'women.jpg'),
('Maison & Jardin', 'Articles pour la maison et le jardin', NULL, 'home.jpg'),
('Cuisine', 'Équipements et ustensiles de cuisine', 7, 'kitchen.jpg'),
('Livres', 'Livres, e-books et audio books', NULL, 'books.jpg'),
('Sport & Loisirs', 'Articles de sport et loisirs', NULL, 'sports.jpg');

-- Produits
INSERT INTO products (name, description, price, discount_percentage, sku, image_url, weight, dimensions, active) VALUES
('iPhone 13', 'Dernier modèle d''iPhone avec écran Super Retina XDR', 999.99, 5.00, 'IP13-BLK-128', 'iphone13.jpg', 0.173, '146.7 x 71.5 x 7.65 mm', TRUE),
('Samsung Galaxy S21', 'Smartphone haut de gamme avec appareil photo professionnel', 899.99, 10.00, 'SAMS21-GRY-256', 'samsungs21.jpg', 0.169, '151.7 x 71.2 x 7.9 mm', TRUE),
('MacBook Pro 16"', 'Ordinateur portable puissant pour professionnels', 2399.99, 0.00, 'MBP16-I9-1TB', 'macbookpro16.jpg', 2.0, '355.7 x 248.1 x 16.2 mm', TRUE),
('Dell XPS 13', 'Ultrabook léger avec écran InfinityEdge', 1299.99, 15.00, 'DXPS13-I7-512', 'dellxps13.jpg', 1.2, '296 x 199 x 14.8 mm', TRUE),
('T-shirt Homme Basique', 'T-shirt en coton 100% biologique', 19.99, 0.00, 'TSHM-BLK-M', 'tshirt-homme.jpg', 0.2, NULL, TRUE),
('Robe d''été Femme', 'Robe légère et élégante pour l''été', 39.99, 20.00, 'ROBF-FLR-S', 'robe-ete.jpg', 0.3, NULL, TRUE),
('Robot Cuisine Multifonction', 'Robot de cuisine avec 10 fonctions différentes', 249.99, 5.00, 'ROBCUI-RED', 'robot-cuisine.jpg', 5.0, '31 x 37 x 30 cm', TRUE),
('Ensemble de Casseroles', 'Set de 5 casseroles en acier inoxydable', 89.99, 0.00, 'CASSET-5P', 'casseroles.jpg', 4.0, NULL, TRUE),
('Harry Potter - Coffret Intégral', 'Collection complète des 7 livres Harry Potter', 79.99, 10.00, 'HPCOF-FR', 'harry-potter.jpg', 3.5, NULL, TRUE),
('Vélo de Montagne', 'Vélo tout-terrain robuste pour sentiers difficiles', 599.99, 0.00, 'VTTMONT-27', 'vtt.jpg', 14.0, NULL, TRUE),
('Écouteurs Sans Fil', 'Écouteurs Bluetooth avec réduction de bruit', 149.99, 15.00, 'ECOUT-BT-BLK', 'ecouteurs.jpg', 0.05, NULL, TRUE),
('Montre Connectée', 'Smartwatch avec suivi d''activité et notifications', 199.99, 0.00, 'WATCH-SM-SLV', 'montre.jpg', 0.04, '44 x 38 x 10.7 mm', TRUE),
('Manteau Hiver Homme', 'Manteau chaud et imperméable', 129.99, 0.00, 'MANTH-BLK-L', 'manteau-homme.jpg', 1.2, NULL, TRUE),
('Jupe Plissée', 'Jupe élégante mi-longue', 49.99, 10.00, 'JUPE-PLS-M', 'jupe.jpg', 0.3, NULL, TRUE),
('Lampe de Bureau LED', 'Lampe ajustable avec plusieurs modes d''éclairage', 39.99, 5.00, 'LAMPLED-WHT', 'lampe-bureau.jpg', 0.8, '15 x 15 x 45 cm', TRUE);

-- Inventaire
INSERT INTO inventory (product_id, quantity) VALUES
(1, 50),
(2, 35),
(3, 20),
(4, 15),
(5, 200),
(6, 100),
(7, 30),
(8, 45),
(9, 60),
(10, 10),
(11, 75),
(12, 40),
(13, 25),
(14, 50),
(15, 60);

-- Relations produits-catégories
INSERT INTO product_categories (product_id, category_id) VALUES
(1, 1), (1, 2), -- iPhone 13 dans Électronique et Smartphones
(2, 1), (2, 2), -- Samsung Galaxy S21 dans Électronique et Smartphones
(3, 1), (3, 3), -- MacBook Pro dans Électronique et Ordinateurs
(4, 1), (4, 3), -- Dell XPS 13 dans Électronique et Ordinateurs
(5, 4), (5, 5), -- T-shirt dans Vêtements et Hommes
(6, 4), (6, 6), -- Robe dans Vêtements et Femmes
(7, 7), (7, 8), -- Robot Cuisine dans Maison & Jardin et Cuisine
(8, 7), (8, 8), -- Casseroles dans Maison & Jardin et Cuisine
(9, 9),         -- Harry Potter dans Livres
(10, 10),       -- Vélo dans Sport & Loisirs
(11, 1),        -- Écouteurs dans Électronique
(12, 1),        -- Montre dans Électronique
(13, 4), (13, 5), -- Manteau dans Vêtements et Hommes
(14, 4), (14, 6), -- Jupe dans Vêtements et Femmes
(15, 7);        -- Lampe dans Maison & Jardin

-- Commandes
INSERT INTO orders (user_id, address_id, payment_id, status, total_amount, shipping_cost, tax, coupon_code, discount_amount) VALUES
(2, 2, 2, 'LIVRÉ', 1049.99, 10.00, 210.00, NULL, 0.00),
(3, 4, 4, 'EXPÉDIÉ', 149.99, 5.00, 30.00, 'BIENVENUE10', 15.00),
(4, 5, 5, 'EN TRAITEMENT', 339.98, 0.00, 68.00, NULL, 0.00),
(5, 6, 6, 'LIVRÉ', 89.99, 5.00, 18.00, NULL, 0.00),
(2, 3, 3, 'ANNULÉ', 599.99, 15.00, 120.00, NULL, 0.00),
(3, 4, 4, 'LIVRÉ', 299.98, 10.00, 60.00, 'ÉTÉ20', 60.00);

-- Éléments de commande
INSERT INTO order_items (order_id, product_id, quantity, price_per_unit, total_price) VALUES
(1, 1, 1, 999.99, 999.99),
(1, 11, 1, 149.99, 149.99),
(2, 11, 1, 149.99, 149.99),
(3, 5, 2, 19.99, 39.98),
(3, 6, 1, 39.99, 39.99),
(3, 14, 1, 49.99, 49.99),
(3, 15, 1, 39.99, 39.99),
(4, 8, 1, 89.99, 89.99),
(5, 10, 1, 599.99, 599.99),
(6, 5, 3, 19.99, 59.97),
(6, 13, 1, 129.99, 129.99),
(6, 14, 2, 49.99, 99.98);

-- Avis
INSERT INTO reviews (product_id, user_id, rating, comment) VALUES
(1, 2, 5, 'Excellent smartphone, je suis très satisfait de mon achat !'),
(1, 3, 4, 'Très bon produit mais un peu cher'),
(2, 4, 5, 'Meilleur smartphone Android que j''ai jamais utilisé'),
(3, 5, 5, 'Puissant et élégant, parfait pour mon travail de designer'),
(5, 3, 3, 'Qualité correcte pour le prix'),
(6, 2, 4, 'Jolie robe, tissu agréable'),
(7, 4, 5, 'Ce robot a changé ma vie ! Tellement polyvalent'),
(9, 5, 5, 'Collection magnifique, mes enfants adorent'),
(11, 2, 2, 'Problèmes de connexion Bluetooth fréquents');

-- Codes promo
INSERT INTO coupons (code, discount_type, discount_value, min_purchase_amount, is_active, start_date, end_date, usage_limit, usage_count) VALUES
('BIENVENUE10', 'PERCENTAGE', 10.00, 50.00, TRUE, '2023-01-01', '2023-12-31', 100, 45),
('ÉTÉ20', 'PERCENTAGE', 20.00, 200.00, TRUE, '2023-06-01', '2023-08-31', 50, 23),
('FRAISPORT', 'FIXED', 10.00, 0.00, TRUE, '2023-05-01', '2023-12-31', NULL, 78),
('NOEL25', 'PERCENTAGE', 25.00, 300.00, FALSE, '2023-12-01', '2023-12-25', 200, 0);

-- Liste de souhaits
INSERT INTO wishlist (user_id, product_id) VALUES
(2, 3),
(2, 7),
(3, 10),
(4, 9),
(4, 12),
(5, 1),
(5, 2);

-- Indices pour optimiser les performances
CREATE INDEX idx_product_categories ON product_categories (product_id, category_id);
CREATE INDEX idx_order_items_order ON order_items (order_id);
CREATE INDEX idx_order_items_product ON order_items (product_id);
CREATE INDEX idx_reviews_product ON reviews (product_id);
CREATE INDEX idx_reviews_user ON reviews (user_id);