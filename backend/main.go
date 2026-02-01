package main

import (
	"backend/misc"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"backend/database"
	"backend/handlers"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

const (
	indexHtml = "index.html"
	staticDir = "./static"
)

func main() {
	if err := database.InitDB(); err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.CloseDB()

	if os.Getenv("GIN_MODE") == "release" {
		gin.SetMode(gin.ReleaseMode)
	} else {
		gin.SetMode(gin.DebugMode)
	}

	router := gin.Default()

	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"*"}
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	config.AllowHeaders = []string{"Origin", "Content-Type", "Accept", "Authorization"}
	router.Use(cors.New(config))

	router.Static("/poem", staticDir)

	router.NoRoute(func(c *gin.Context) {
		filePath := filepath.Join(staticDir, c.Request.URL.Path)
		if _, err := os.Stat(filePath); err == nil {
			c.File(filePath)
			return
		}

		if len(c.Request.URL.Path) >= 4 && c.Request.URL.Path[:4] == "/api" {
			c.JSON(http.StatusNotFound, gin.H{
				"code": http.StatusNotFound,
				"msg":  "Not found",
			})
			return
		}

		c.File(filepath.Join(staticDir, indexHtml))
	})

	api := router.Group("/api")
	{
		api.GET("/poems", handlers.GetPoems)
		api.GET("/poem/:id", handlers.GetPoemByID)
		api.POST("/poem", handlers.CreatePoem)
		api.POST("/poem/:id", handlers.RenewPoemByID)
		api.DELETE("/poem/:id", handlers.RemovePoemByID)
	}

	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "OK",
			"code":   http.StatusOK,
			"msg":    "Poem is running",
		})
	})

	port := misc.Getenv("PORT")
	log.Printf("Server starting on port %s", port)
	log.Printf("Static files directory: %s", staticDir)

	server := &http.Server{
		Addr:         ":" + port,
		Handler:      router,
		WriteTimeout: 60 * time.Second,
	}

	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
