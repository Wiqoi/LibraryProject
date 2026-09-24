package main

import(
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
)

func main(){
	app:=fiber.New(fiber.Config{
		AppName: "Library Game",
	})
	app.Use(logger.New())
	app.Use(recover.New())
	distPath, err:=filepath.Abs(".")
	if err!=nil{
		log.Fatalf("Failed to resolve dist path: %v", err)
	}
	findEntry:=func(dir string) string{
		for _, name:=range []string{"index.html", "LibraryProject.html"}{
			if _, err:=os.Stat(filepath.Join(dir, name)); err==nil{
				return name
			}
		}
		return ""
	}
	// The web export may live next to the server or in an ./export folder.
	entry:=findEntry(distPath)
	if entry==""{
		exportDir:=filepath.Join(distPath, "export")
		if e:=findEntry(exportDir); e!=""{
			distPath=exportDir
			entry=e
		}
	}
	if entry==""{
		log.Fatalf("No web export found in %s. Did you export the Web build?", distPath)
	}
	app.Use("/", func(c *fiber.Ctx) error{
		requestPath:=c.Path()
		fullPath:=filepath.Join(distPath, requestPath)
		if rel, err:=filepath.Rel(distPath, fullPath); err!=nil||rel==".."||strings.HasPrefix(rel, ".."+string(os.PathSeparator)){
			return c.Next()
		}
		if info, err:=os.Stat(fullPath); err==nil&&!info.IsDir(){
			ext:=strings.ToLower(filepath.Ext(fullPath))
			switch ext{
			case ".html", ".css", ".js", ".ts", ".map":
				c.Set("Cache-Control", "no-cache, no-store, must-revalidate")
			case ".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg", ".ico",
				".mp4", ".webm", ".ogg",
				".woff", ".woff2", ".ttf", ".eot":
				c.Set("Cache-Control", "public, max-age=31536000, immutable")
			default:
				c.Set("Cache-Control", "no-cache")
			}
			return c.SendFile(fullPath)
		}
		return c.Next()
	})
	app.Use("*", func(c *fiber.Ctx) error{
		if strings.HasPrefix(c.Path(), "/api"){
			return c.Next()
		}
		c.Set("Cache-Control", "no-cache, no-store, must-revalidate")
		return c.SendFile(filepath.Join(distPath, entry))
	})
	port:=os.Getenv("PORT")
	if port==""{
		port="1331"
	}
	log.Printf("Server starting on http://localhost:%s", port)
	log.Fatal(app.Listen(":"+port))
}