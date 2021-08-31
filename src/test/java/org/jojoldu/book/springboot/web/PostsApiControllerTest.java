package org.jojoldu.book.springboot.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.assertj.core.api.Assertions;
import org.jojoldu.book.springboot.domain.posts.Posts;
import org.jojoldu.book.springboot.domain.posts.PostsRepository;
import org.jojoldu.book.springboot.web.dto.PostsSaveRequestDto;
import org.jojoldu.book.springboot.web.dto.PostsUpdateRequestDto;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import java.util.List;


@ExtendWith(SpringExtension.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class PostsApiControllerTest {
    @LocalServerPort
    private int port;

    @Autowired
    private PostsRepository postsRepository;

    @Autowired
    private WebApplicationContext context;

    private MockMvc mvc;

    @BeforeEach
    public void setUp() throws Exception {
        mvc = MockMvcBuilders
                .webAppContextSetup(context)
                .apply(SecurityMockMvcConfigurers.springSecurity())
                .build();
    }

    @AfterEach
    public void tearDown() throws Exception {
        postsRepository.deleteAll();
    }

    @Test
    @WithMockUser(roles = "USER")
    public void save_single_Posts() throws Exception {
        //given
        String title = "title";
        String content = "content";
        PostsSaveRequestDto requestDto = PostsSaveRequestDto.builder().title(title).content(content).author("author").build();
        String url = "http://localhost:" + port + "/api/v1/posts";

        //when
        ResultActions result = mvc.perform(MockMvcRequestBuilders.post(url)
                .contentType(MediaType.APPLICATION_JSON_UTF8)
                .content(new ObjectMapper().writeValueAsString(requestDto)));

        //then
        result.andExpect(MockMvcResultMatchers.status().isOk());
        List<Posts> all = postsRepository.findAll();
        Assertions.assertThat(all.get(0).getTitle()).isEqualTo(title);
        Assertions.assertThat(all.get(0).getContent()).isEqualTo(content);
    }

    @Test
    @WithMockUser(roles = "USER")
    public void update_single_Posts() throws Exception {
        //given
        Posts savedPosts = postsRepository.save(Posts.builder().title("title").content("content").author("author").build());

        Long updatedId = savedPosts.getId();
        String expectedTitle = "title2";
        String expectedContent = "content2";
        PostsUpdateRequestDto requestDto = PostsUpdateRequestDto.builder().title(expectedTitle).content(expectedContent).build();
        HttpEntity<PostsUpdateRequestDto> requestEntity = new HttpEntity<>(requestDto);
        String url = "http://localhost:" + port + "/api/v1/posts/" + updatedId;

        //when
        ResultActions result = mvc.perform(MockMvcRequestBuilders.put(url)
                .contentType(MediaType.APPLICATION_JSON_UTF8)
                .content(new ObjectMapper().writeValueAsString(requestDto)));

        //then
        result.andExpect(MockMvcResultMatchers.status().isOk());
        List<Posts> all = postsRepository.findAll();
        Assertions.assertThat(all.get(0).getTitle()).isEqualTo(expectedTitle);
        Assertions.assertThat(all.get(0).getContent()).isEqualTo(expectedContent);
    }

    @Test
    @WithMockUser(roles = "USER")
    public void find_single_Posts() throws Exception {
        //given
        String title = "title";
        String content = "content";
        String author = "author";
        Posts savedPosts = postsRepository.save(Posts.builder().title(title).content(content).author(author).build());

        Long id = savedPosts.getId();
        String url = "http://localhost:" + port + "/api/v1/posts/" + id;

        //when
        ResultActions result = mvc.perform(MockMvcRequestBuilders.get(url)
                .contentType(MediaType.APPLICATION_JSON_UTF8));


        //then
        result.andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(MockMvcResultMatchers.jsonPath("$.title").value(title))
                .andExpect(MockMvcResultMatchers.jsonPath("$.content").value(content))
                .andExpect(MockMvcResultMatchers.jsonPath("$.author").value(author));
    }
}
