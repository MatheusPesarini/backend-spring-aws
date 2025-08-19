package com.example.backend.note;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface NoteRepository extends JpaRepository<Note, UUID> {
}

