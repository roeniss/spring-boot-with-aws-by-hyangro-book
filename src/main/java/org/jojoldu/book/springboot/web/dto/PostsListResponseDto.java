package org.jojoldu.book.springboot.web.dto;

import lombok.Value;
import org.jojoldu.book.springboot.domain.posts.Posts;

import java.time.LocalDateTime;

@Value
public class PostsListResponseDto {
    Long id;
    String title;
    String author;
    LocalDateTime modifiedDate;

    public PostsListResponseDto(Posts posts) {
        this.id = posts.getId();
        this.title = posts.getTitle();
        this.author = posts.getAuthor();
        this.modifiedDate = posts.getModifiedDate();
    }
}
