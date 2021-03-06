package org.jojoldu.book.springboot.service;

import org.assertj.core.api.Assertions;
import org.jojoldu.book.springboot.domain.posts.Posts;
import org.jojoldu.book.springboot.domain.posts.PostsRepository;
import org.jojoldu.book.springboot.web.dto.PostsListResponseDto;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import java.util.List;

@ExtendWith(SpringExtension.class)
@SpringBootTest
public class PostsServiceTest {
    @Autowired
    PostsService postsService;
    @Autowired
    PostsRepository postsRepository;

    @AfterEach
    public void cleanup() throws Exception {
        postsRepository.deleteAll();
    }

    @Test
    public void find_multiple_posts_order_by_modifiedDate_desc() {
        //given
        String title1 = "title1";
        String title2 = "title2";
        String title3 = "title3";
        postsRepository.save(Posts.builder().title(title1).content("content").author("author").build());
        postsRepository.save(Posts.builder().title(title2).content("content").author("author").build());
        postsRepository.save(Posts.builder().title(title3).content("content").author("author").build());

        //then
        List<PostsListResponseDto> dtoList = postsService.findAllDesc();

        //then
        Assertions.assertThat(dtoList.size()).isEqualTo(3);
        Assertions.assertThat(dtoList.get(0).getTitle()).isEqualTo(title3);
        Assertions.assertThat(dtoList.get(1).getTitle()).isEqualTo(title2);
        Assertions.assertThat(dtoList.get(2).getTitle()).isEqualTo(title1);
    }
}
