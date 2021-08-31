package org.jojoldu.book.springboot.web;

import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.env.Environment;
import org.springframework.http.MediaType;
import org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;


@ExtendWith(SpringExtension.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class ProfileControllerWithSecurityTest {
    @Autowired
    private WebApplicationContext context;
    @Autowired
    private Environment env;
    private MockMvc mvc;

    @BeforeEach
    public void setUp() throws Exception {
        mvc = MockMvcBuilders
                .webAppContextSetup(context)
                .apply(SecurityMockMvcConfigurers.springSecurity())
                .build();
    }

    @Test
    public void load_index_page() throws Exception {
        //given
        String expectedProfile = env.getActiveProfiles()[0];

        //when
        String result = mvc.perform(MockMvcRequestBuilders.get("/profile")
                .contentType(MediaType.APPLICATION_JSON_UTF8))
                .andReturn().getResponse().getContentAsString();

        //then
        Assertions.assertThat(result).contains(expectedProfile);
    }
}
