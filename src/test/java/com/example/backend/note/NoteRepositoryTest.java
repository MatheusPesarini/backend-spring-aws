package com.example.backend.note;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@ActiveProfiles("test")
class NoteRepositoryTest {

    @Autowired
    private NoteRepository repository;

    @Test
    void saveAndFind() {
        Note n = new Note();
        n.setTitle("hello");
        n.setContent("world");
        Note saved = repository.save(n);
        assertThat(saved.getId()).isNotNull();
        assertThat(repository.findById(saved.getId())).isPresent();
    }
}

