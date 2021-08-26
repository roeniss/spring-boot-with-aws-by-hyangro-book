package org.jojoldu.book.springboot.config.auth.dto;

import lombok.Builder;
import lombok.Getter;
import org.jojoldu.book.springboot.domain.user.Role;
import org.jojoldu.book.springboot.domain.user.User;

import java.util.Map;

@Getter
public class OAuthAttributes {
    private Map<String, Object> attributes;
    private String nameAttributeKey;
    private String name;
    private String email;
    private String picture;

    @Builder
    public OAuthAttributes(Map<String, Object> attributes, String nameAttributeKey, String name, String email, String picture) {
        this.attributes = attributes;
        this.nameAttributeKey = nameAttributeKey;
        this.name = name;
        this.email = email;
        this.picture = picture;
    }

    public static OAuthAttributes of(String registrationId, String userNameAttributeName, Map<String, Object> attributes) {
        switch(registrationId.toLowerCase()){
            case "google":
                return ofGoogle(userNameAttributeName, attributes);
            case "naver":
                return ofNaver("id", attributes);
            default:
                throw new IllegalArgumentException("Unknown registrationId=" + registrationId);
        }
    }

    private static OAuthAttributes ofGoogle(String userNameAttributeName, Map<String, Object> attributes) {
        System.out.println("principal=" + attributes.get(userNameAttributeName));
        return OAuthAttributes.builder()
                .name((String) attributes.get("name"))
                .email((String) attributes.get("email"))
                .picture((String) attributes.get("picture"))
                .attributes(attributes)
                .nameAttributeKey(userNameAttributeName)
                .build();
    }

    private static OAuthAttributes ofNaver(String userNameAttributeName, Map<String, Object> attributes) {
        Map<String, Object> attr = (Map<String, Object>) attributes.get("response");
        System.out.println("principal=" + attr.get(userNameAttributeName));

        return OAuthAttributes.builder()
                .name((String) attr.get("name"))
                .email((String) attr.get("email"))
                .picture((String) attr.get("profile_image"))
                .attributes(attr)
                .nameAttributeKey(userNameAttributeName)
                .build();
    }

    public User toEntity() {
        return User.builder()
                .name(name)
                .email(email)
                .picture(picture)
                .role(Role.GUEST)
                .build();
    }
}

