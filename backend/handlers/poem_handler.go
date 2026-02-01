package handlers

import (
	"backend/llm"
	"database/sql"
	"errors"
	"log"
	"net/http"
	"strconv"

	"backend/database"
	"backend/models"

	"github.com/gin-gonic/gin"
)

func GetPoems(c *gin.Context) {
	rows, err := database.DB.Query("SELECT id, name, author, content FROM poems ORDER BY updated_at DESC")
	if err != nil {
		log.Printf("Failed to query poems: %v", err)
		c.JSON(http.StatusInternalServerError, models.Failed(500, "Failed to fetch poems: "+err.Error()))
		return
	}
	defer rows.Close()

	poems := make([]models.Poem, 0, 8)
	for rows.Next() {
		var poem models.Poem
		if err := rows.Scan(&poem.ID, &poem.Name, &poem.Author, &poem.Content); err != nil {
			log.Printf("Failed to scan poem row: %v", err)
			continue
		}
		poems = append(poems, poem)
	}

	if err := rows.Err(); err != nil {
		log.Printf("Error iterating rows: %v", err)
		c.JSON(http.StatusInternalServerError, models.Failed(500, "Failed to process poems: "+err.Error()))
		return
	}

	c.JSON(http.StatusOK, models.Succeed(poems))
}

func GetPoemByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.Failed(400, "Invalid poem ID"))
		return
	}

	var poem models.Poem
	err = database.DB.QueryRow(
		"SELECT id, name, author, content, note, modern_chinese, comment FROM poems WHERE id = ?",
		id,
	).Scan(&poem.ID, &poem.Name, &poem.Author, &poem.Content, &poem.Note, &poem.ModernChinese, &poem.Comment)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			c.JSON(http.StatusNotFound, models.Failed(404, "Poem not found"))
		} else {
			log.Printf("Failed to query poem: %v", err)
			c.JSON(http.StatusInternalServerError, models.Failed(500, "Failed to fetch poem: "+err.Error()))
		}
		return
	}

	c.JSON(http.StatusOK, models.Succeed(poem))
}

func CreatePoem(c *gin.Context) {
	var req models.CreatePoemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.Failed(400, "Invalid request data"))
		return
	}

	createdPoem, err := llm.CreatePoem(req.Name, req.Author, req.Content)
	if err != nil {
		log.Printf("Failed to create poem: %v", err)
		c.JSON(http.StatusInternalServerError, models.Failed(500, "Failed to create poem: "+err.Error()))
		return
	}

	var poem models.Poem
	err = database.DB.QueryRow(
		"SELECT id, comment FROM poems WHERE name = ? and author = ?",
		createdPoem.Name, createdPoem.Author,
	).Scan(&poem.ID, &poem.Comment)

	if err == nil {
		_, err = database.DB.Exec(
			"UPDATE poems SET content = ?, note = ?, modern_chinese = ? WHERE id = ?",
			createdPoem.Content, createdPoem.Note, createdPoem.ModernChinese, poem.ID,
		)
		if err != nil {
			log.Printf("Failed to update poem: %v", err)
			c.JSON(http.StatusInternalServerError, models.Failed(500, "Failed to update poem: "+err.Error()))
			return
		}

		c.JSON(http.StatusOK, models.Succeed(models.Poem{
			ID:            poem.ID,
			Name:          createdPoem.Name,
			Author:        createdPoem.Author,
			Content:       createdPoem.Content,
			Note:          createdPoem.Note,
			ModernChinese: createdPoem.ModernChinese,
			Comment:       poem.Comment,
		}))
		return
	}

	if !errors.Is(err, sql.ErrNoRows) {
		log.Printf("Failed to query poem: %v", err)
		c.JSON(http.StatusInternalServerError, models.Failed(500, "Failed to fetch poem: "+err.Error()))
		return
	}

	result, err := database.DB.Exec(
		"INSERT INTO poems (name, author, content, note, modern_chinese, comment) VALUE (?, ?, ?, ?, ?, ?)",
		createdPoem.Name, createdPoem.Author, createdPoem.Content, createdPoem.Note, createdPoem.ModernChinese, createdPoem.Comment,
	)
	if err != nil {
		log.Printf("Failed to insert poem: %v", err)
		c.JSON(http.StatusInternalServerError, models.Failed(500, "Failed to create poem: "+err.Error()))
		return
	}

	id, err := result.LastInsertId()
	if err != nil {
		log.Printf("Failed to get last insert ID: %v", err)
		c.JSON(http.StatusInternalServerError, models.Failed(500, "Failed to get poem ID: "+err.Error()))
		return
	}

	c.JSON(http.StatusCreated, models.Succeed(models.Poem{
		ID:            int(id),
		Name:          createdPoem.Name,
		Author:        createdPoem.Author,
		Content:       createdPoem.Content,
		Note:          createdPoem.Note,
		ModernChinese: createdPoem.ModernChinese,
		Comment:       createdPoem.Comment,
	}))
}

func RenewPoemByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.Failed(400, "Invalid poem ID"))
		return
	}

	var req models.RenewPoemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.Failed(400, "Invalid request data"))
		return
	}

	_, err = database.DB.Exec(
		"UPDATE poems SET content = ?, note = ?, modern_chinese = ?, comment = ? WHERE id = ?",
		req.Content, req.Note, req.ModernChinese, req.Comment, id,
	)
	if err != nil {
		log.Printf("Failed to update poem: %v", err)
		c.JSON(http.StatusInternalServerError, models.Failed(500, "Failed to update poem: "+err.Error()))
		return
	}

	c.JSON(http.StatusOK, models.Succeed(nil))
}

func RemovePoemByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.Failed(400, "Invalid poem ID"))
		return
	}

	_, err = database.DB.Exec(
		"DELETE FROM poems WHERE id = ?", id,
	)
	if err != nil {
		log.Printf("Failed to remove poem: %v", err)
		c.JSON(http.StatusInternalServerError, models.Failed(500, "Failed to remove poem: "+err.Error()))
		return
	}

	c.JSON(http.StatusOK, models.Succeed(nil))
}
