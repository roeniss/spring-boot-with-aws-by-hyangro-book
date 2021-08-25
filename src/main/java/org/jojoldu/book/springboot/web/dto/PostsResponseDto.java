package org.jojoldu.book.springboot.web.dto;

import lombok.Value;
import org.jojoldu.book.springboot.domain.posts.Posts;

@Value
public class PostsResponseDto {
    Long id;
    String title;
    String content;
    String author;

    public PostsResponseDto(Posts posts) {
        this.id = posts.getId();
        this.title = posts.getTitle();
        this.content = posts.getContent();
        this.author = posts.getAuthor();
    }
}
