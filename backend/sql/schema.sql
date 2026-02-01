CREATE DATABASE IF NOT EXISTS culture;
USE culture;

CREATE TABLE IF NOT EXISTS poems
(
    id             INT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(64) NOT NULL,
    author         VARCHAR(16) NOT NULL,
    content        TEXT        NOT NULL,
    note           TEXT        NOT NULL,
    modern_chinese TEXT        NOT NULL,
    comment        TEXT        NOT NULL,
    created_at     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name_author (name, author)
) CHARSET utf8mb4;