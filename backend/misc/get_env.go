package misc

import (
	"os"

	_ "github.com/joho/godotenv/autoload"
)

func Getenv(key string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}

	panic("Missing environment variable: " + key)
}
