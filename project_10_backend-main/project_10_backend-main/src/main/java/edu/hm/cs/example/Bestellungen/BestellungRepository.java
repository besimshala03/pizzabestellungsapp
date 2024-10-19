package edu.hm.cs.example.Bestellungen;

import org.springframework.data.jpa.repository.JpaRepository;

public interface BestellungRepository extends JpaRepository<Bestellung, Long> {
}
