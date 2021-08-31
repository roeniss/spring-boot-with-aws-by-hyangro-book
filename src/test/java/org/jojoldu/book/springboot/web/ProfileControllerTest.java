package org.jojoldu.book.springboot.web;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.mock.env.MockEnvironment;

import static org.junit.jupiter.api.Assertions.*;


class ProfileControllerTest {

    @Test
    void find_real_profiles() {
        // given
        String expectedProfile = "real";
        MockEnvironment env = new MockEnvironment();
        env.addActiveProfile(expectedProfile);
        env.addActiveProfile("oauth");
        env.addActiveProfile("real-db");

        ProfileController profileController = new ProfileController(env);

        // when
        String profile = profileController.profile();

        // then
        Assertions.assertThat(profile).isEqualTo(expectedProfile);
    }

    @Test
    void find_first_profile_if_real_profile_not_exists() {
        // given
        String expectedProfile = "oauth";
        MockEnvironment env = new MockEnvironment();
        env.addActiveProfile(expectedProfile);
        env.addActiveProfile("real-db");

        ProfileController profileController = new ProfileController(env);

        // when
        String profile = profileController.profile();

        // then
        Assertions.assertThat(profile).isEqualTo(expectedProfile);
    }

    @Test
    void find_first_profile_if_profiles_not_exist() {
        // given
        String expectedProfile = "default";
        MockEnvironment env = new MockEnvironment();

        ProfileController profileController = new ProfileController(env);

        // when
        String profile = profileController.profile();

        // then
        Assertions.assertThat(profile).isEqualTo(expectedProfile);
    }
}
