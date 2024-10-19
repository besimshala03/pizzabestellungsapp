package edu.hm.cs.example;

import edu.hm.cs.example.Bestellungen.BestellungRepository;
import edu.hm.cs.example.Getraenke.GetraenkeRepository;
import edu.hm.cs.example.Pizza.PizzaRepository;
import edu.hm.cs.example.zutaten.ZutatenRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class PizzaBestellungsApplicationTest {

    @Autowired
    private BestellungRepository bestellungRepository;

    @Autowired
    private PizzaRepository pizzaRepository;

    @Autowired
    private GetraenkeRepository getraenkeRepository;

    @Autowired
    private ZutatenRepository zutatenRepository;

    @BeforeEach
    public void setUp() {
        bestellungRepository.deleteAll();
        pizzaRepository.deleteAll();
        getraenkeRepository.deleteAll();
        zutatenRepository.deleteAll();
    }

    @Test
    public void contextLoads() {
        // Test that the application context loads successfully
        PizzaBestellungsApplication.main(new String[] {});
    }


}
