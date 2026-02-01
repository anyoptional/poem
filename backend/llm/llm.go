package llm

import (
	"backend/misc"
	"context"
	_ "embed"
	"encoding/json"
	"log"
	"strings"
	"time"

	"github.com/openai/openai-go/v3"
	"github.com/openai/openai-go/v3/option"
)

//go:embed prompt.md
var defaultSystemPrompt string

var (
	client openai.Client
	model  = misc.Getenv("OPENAI_MODEL")
)

type Poem struct {
	Name          string `json:"name"`
	Author        string `json:"author"`
	Content       string `json:"content"`
	Note          string `json:"note"`
	ModernChinese string `json:"modernChinese"`
	Comment       string `json:"comment"`
}

func init() {
	llmApiKey := misc.Getenv("OPENAI_API_KEY")
	llmBaseUrl := misc.Getenv("OPENAI_BASE_URL")
	client = openai.NewClient(
		option.WithBaseURL(llmBaseUrl),
		option.WithAPIKey(llmApiKey),
		option.WithRequestTimeout(55*time.Second),
		option.WithMaxRetries(0),
	)

	log.Println("LLM client created successfully")
}
func CreatePoem(name, author, content string) (Poem, error) {
	chat, err := client.Chat.Completions.New(context.TODO(), openai.ChatCompletionNewParams{
		Messages: []openai.ChatCompletionMessageParamUnion{
			openai.SystemMessage(defaultSystemPrompt),
			openai.UserMessage(promptOf(name, author, content)),
		},
		ResponseFormat: openai.ChatCompletionNewParamsResponseFormatUnion{
			OfJSONObject: &openai.ResponseFormatJSONObjectParam{},
		},
		Model: model,
	})
	if err != nil {
		return Poem{}, err
	}

	var poem Poem
	err = json.Unmarshal([]byte(chat.Choices[0].Message.Content), &poem)
	if err != nil {
		return Poem{}, err
	}

	return poem, nil
}

func promptOf(name, author, content string) string {
	var sb strings.Builder
	sb.WriteString("将")
	sb.WriteString(author)
	if len(content) > 0 {
		sb.WriteString("有名句“")
		sb.WriteString(content)
		sb.WriteString("”")
	}
	sb.WriteString("的")
	sb.WriteString("「")
	sb.WriteString(name)
	sb.WriteString("」翻译成白话文，并给出注释和赏析。")
	return sb.String()
}
