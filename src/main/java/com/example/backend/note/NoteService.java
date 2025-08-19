package com.example.backend.note;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class NoteService {
    private final NoteRepository repository;

    public NoteService(NoteRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public List<Note> list() {
        return repository.findAll();
    }

    @Transactional(readOnly = true)
    public Note get(UUID id) {
        return repository.findById(id).orElseThrow(() -> new NoteNotFoundException(id));
    }

    public Note create(Note note) {
        note.setId(null);
        return repository.save(note);
    }

    public void delete(UUID id) {
        if (!repository.existsById(id)) {
            throw new NoteNotFoundException(id);
        }
        repository.deleteById(id);
    }
}

