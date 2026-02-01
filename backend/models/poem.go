package models

import "time"

type Poem struct {
	ID            int       `json:"id"`
	Name          string    `json:"name"`
	Author        string    `json:"author"`
	Content       string    `json:"content"`
	Note          string    `json:"note"`
	ModernChinese string    `json:"modernChinese"`
	Comment       string    `json:"comment"`
	CreatedAt     time.Time `json:"createdAt"`
	UpdatedAt     time.Time `json:"updatedAt"`
}

type CreatePoemRequest struct {
	Name    string `json:"name" binding:"required"`
	Author  string `json:"author" binding:"required"`
	Content string `json:"content,omitempty"`
}

type RenewPoemRequest struct {
	Content       string `json:"content"`
	Note          string `json:"note"`
	ModernChinese string `json:"modernChinese"`
	Comment       string `json:"comment"`
}

type Result struct {
	Code int         `json:"code"`
	Msg  string      `json:"msg"`
	Data interface{} `json:"data"`
}

func Succeed(data interface{}) Result {
	return Result{
		Code: 200,
		Msg:  "success",
		Data: data,
	}
}

func Failed(code int, msg string) Result {
	return Result{
		Code: code,
		Msg:  msg,
		Data: nil,
	}
}
