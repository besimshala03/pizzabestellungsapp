package edu.hm.cs.example.controller;


import edu.hm.cs.example.Bestellungen.Bestellung;
import edu.hm.cs.example.Bestellungen.BestellungRepository;
import edu.hm.cs.example.Getraenke.Getraenke;
import edu.hm.cs.example.Getraenke.GetraenkeRepository;
import edu.hm.cs.example.Pizza.Pizza;
import edu.hm.cs.example.Pizza.PizzaRepository;
import edu.hm.cs.example.zutaten.Zutaten;
import edu.hm.cs.example.zutaten.ZutatenRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@CrossOrigin(origins = {"http://10.28.55.0", "http://localhost:*"})
@RestController
public class Controller {

    private static final Logger logger = LoggerFactory.getLogger(Controller.class);


    @Autowired
    ZutatenRepository zutatenRepository;
    @Autowired
    private PizzaRepository pizzaRepository;

    @Autowired
    private BestellungRepository bestellungRepository;

    @Autowired
    private GetraenkeRepository getraenkeRepository;

    @GetMapping("/zutaten")
    public List<Zutaten> fetchZutatenData() {
        List<Zutaten> allPizzas = zutatenRepository.findAll();
        return allPizzas.stream()
                .filter(Zutaten::isPredefined)
                .collect(Collectors.toList());
    }

    @DeleteMapping("/pizza/{id}")
    public ResponseEntity<String> deletePizzaByID(@PathVariable Long id) {
        try {
            Pizza pizza = pizzaRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Pizza nicht gefunden"));

            pizzaRepository.delete(pizza);

            return ResponseEntity.ok().body("Pizza erfolgreich gelöscht");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Fehler beim Löschen der Pizza: " + e.getMessage());
        }
    }

    @DeleteMapping("/getraenke/{id}")
    public ResponseEntity<String> deleteGetraenkeByID(@PathVariable Long id) {
        try {
            Getraenke getraenke = getraenkeRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Getränk nicht gefunden"));

            // Entferne den Bezug zur Bestellung
            getraenke.setOrderG(null);
            getraenkeRepository.save(getraenke);

            return ResponseEntity.ok().body("Getränk erfolgreich von der Bestellung entfernt");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Fehler beim Entfernen des Getränks von der Bestellung: " + e.getMessage());
        }
    }


    @GetMapping("/zutaten/{id}")
    public Zutaten getZutatById(@PathVariable Long id) {
        return zutatenRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Zutat nicht gefunden"));
    }

    @GetMapping("/pizza")
    public List<Pizza> fetchPizzaData() {
        List<Pizza> allPizzas = pizzaRepository.findAll();
        return allPizzas.stream()
                .filter(Pizza::isPredefined)
                .collect(Collectors.toList());
    }

    @GetMapping("/pizza/{id}")
    public Pizza getPizzaById(@PathVariable Long id) {
        return pizzaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pizza nicht gefunden"));
    }


    @GetMapping("/getraenke")
    public List<Getraenke> fetchGetraenkeData() {
        return getraenkeRepository.findAll();
    }

    @GetMapping("/getraenke/{id}")
    public Getraenke getGetraenkeById(@PathVariable Long id) {
        return getraenkeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Getränk nicht gefunden"));
    }

    @PostMapping("/pizzen")
    public Pizza createPizza() {
        List<Zutaten> zutat = zutatenRepository.findAll();
        Pizza pizza = pizzaRepository.findById(1L).orElseThrow(() -> new RuntimeException("Pizza nicht gefunden"));
        pizza.setZutaten(zutat);
        zutat.forEach(zutaten -> zutaten.setPizzazutaten(pizza));
        return pizzaRepository.save(pizza);
    }

    @PostMapping("/bestellung")
    public Bestellung addBestellung(@RequestBody Bestellung bestellung) {
        System.out.println(bestellung);

        // Erstellen neuer Pizzen und deren Zutaten für die Bestellung
        List<Pizza> newPizzas = new ArrayList<>();
        for (Pizza pizza : bestellung.getPizzas()) {
            Pizza newPizza = new Pizza();
            newPizza.setName(pizza.getName());
            newPizza.setBeschreibung(pizza.getBeschreibung());
            newPizza.setPreis(pizza.getPreis());
            newPizza.setImageUrl(pizza.getImageUrl());
            newPizza.setOrderP(bestellung);
            newPizza.setPredefined(false);

            List<Zutaten> newZutaten = new ArrayList<>();
            for (Zutaten zutat : pizza.getZutaten()) {
                Zutaten newZutat = new Zutaten();
                newZutat.setName(zutat.getName());
                newZutat.setPreis(zutat.getPreis());
                newZutat.setPizzazutaten(newPizza);
                newZutat.setPredefined(false);
                newZutaten.add(newZutat);


            }
            newPizza.setZutaten(newZutaten);

            newPizzas.add(newPizza);
        }
        bestellung.setPizzas(newPizzas);

        // Überprüfen, ob die Getränke in der Datenbank vorhanden sind und sie zur Bestellung hinzufügen
        List<Getraenke> validGetraenke = new ArrayList<>();
        for (Getraenke getraenk : bestellung.getGetraenke()) {
            Getraenke validGetraenk = getraenkeRepository.findById(getraenk.getId())
                    .orElseThrow(() -> new RuntimeException("Getränk nicht gefunden: " + getraenk.getId()));
            validGetraenk.setOrderG(bestellung);
            validGetraenke.add(validGetraenk);
        }
        bestellung.setGetraenke(validGetraenke);

        bestellung.calculateTotalPrice();


        // Speichern und Rückgabe der neuen Bestellung
        return bestellungRepository.save(bestellung);
    }

    @DeleteMapping("/bestellung/{id}")
    public ResponseEntity<String> deleteBestellungById(@PathVariable Long id) {
        try {
            Bestellung bestellung = bestellungRepository.findById(id).orElseThrow(() -> new RuntimeException("Bestellung nicht gefunden"));

            // Entferne die Beziehung zu Pizzen
            for (Pizza pizza : bestellung.getPizzas()) {
                pizza.setOrderP(null);
                pizzaRepository.save(pizza); // Speichern, um die Änderungen zu übernehmen
            }
            bestellung.setPizzas(new ArrayList<>());

            // Entferne die Beziehung zu Getränken
            for (Getraenke getraenk : bestellung.getGetraenke()) {
                getraenk.setOrderG(null);
                getraenkeRepository.save(getraenk); // Speichern, um die Änderungen zu übernehmen
            }
            bestellung.setGetraenke(new ArrayList<>());

            // Jetzt kann die Bestellung sicher gelöscht werden
            bestellungRepository.delete(bestellung);

            return ResponseEntity.ok().body("Bestellung erfolgreich gelöscht");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Fehler beim Löschen der Bestellung: " + e.getMessage());
        }
    }

    @GetMapping("/bestellung/{id}")
    public Bestellung getBestellungById(@PathVariable Long id) {
        return bestellungRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Bestellung nicht gefunden"));
    }

    @PutMapping("/bestellung/{id}")
    public ResponseEntity<Bestellung> updateBestellung(@PathVariable Long id, @RequestBody Bestellung bestellungDetails) {
        try {
            Bestellung existingBestellung = bestellungRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Bestellung nicht gefunden"));

            // Aktualisieren der Attribute der Bestellung
            existingBestellung.setDatumUhrzeit(bestellungDetails.getDatumUhrzeit());
            existingBestellung.setAdresse(bestellungDetails.getAdresse());
            existingBestellung.setKundenname(bestellungDetails.getKundenname());

            existingBestellung.calculateTotalPrice();

            // Speichern der aktualisierten Bestellung
            Bestellung updatedBestellung = bestellungRepository.save(existingBestellung);

            return new ResponseEntity<>(updatedBestellung, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/pizza/{id}")
    public ResponseEntity<Pizza> updatePizza(@PathVariable Long id, @RequestBody Pizza pizzaDetails) {
        try {
            Pizza existingPizza = pizzaRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Pizza nicht gefunden"));

            // Alle Pizzen laden und die vordefinierten filtern
            List<Pizza> allPizzas = pizzaRepository.findAll();
            List<Pizza> predefinedPizzas = allPizzas.stream()
                    .filter(Pizza::isPredefined)
                    .collect(Collectors.toList());

            // Basispreis aus den vordefinierten Pizzen holen
            double basePrice = 0.0;
            for (Pizza predefinedPizza : predefinedPizzas) {
                if (predefinedPizza.getName().equals(existingPizza.getName())) {
                    basePrice = predefinedPizza.getPreis();
                    break;
                }
            }

            // Aktualisieren der grundlegenden Attribute der Pizza
            existingPizza.setName(pizzaDetails.getName());
            existingPizza.setBeschreibung(pizzaDetails.getBeschreibung());
            existingPizza.setImageUrl(pizzaDetails.getImageUrl());

            // Hinzufügen der neuen Zutaten, dabei Duplikate vermeiden
            Set<String> uniqueZutatenNames = new HashSet<>();
            List<Zutaten> uniqueZutaten = new ArrayList<>();
            for (Zutaten zutat : pizzaDetails.getZutaten()) {
                if (uniqueZutatenNames.add(zutat.getName())) {
                    Zutaten newZutat = new Zutaten();
                    newZutat.setName(zutat.getName());
                    newZutat.setPreis(zutat.getPreis());
                    newZutat.setPizzazutaten(existingPizza); // Setze die Beziehung zur Pizza
                    uniqueZutaten.add(newZutat);
                }
            }

            existingPizza.setZutaten(uniqueZutaten);

            // Berechne den neuen Preis
            double newPrice = basePrice; // Basispreis
            for (Zutaten zutat : uniqueZutaten) {
                newPrice += zutat.getPreis(); // Preis der Zutaten hinzufügen
            }
            existingPizza.setPreis(newPrice); // Setze den neuen Preis
            // Speichern der aktualisierten Pizza
            Pizza updatedPizza = pizzaRepository.save(existingPizza);

            return new ResponseEntity<>(updatedPizza, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("Fehler beim Aktualisieren der Pizza: ", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/bestellung")
    public List<Bestellung> fetchBestellungData() {
        return bestellungRepository.findAll();
    }

    @DeleteMapping("/zutaten")
    public ResponseEntity<String> deleteZutatenByPizza(@RequestBody Pizza pizza) {
        try {

            Pizza existingPizza = pizzaRepository.findById(pizza.getId())
                    .orElseThrow(() -> new RuntimeException("Pizza nicht gefunden"));
            // Löschen der alten Zutaten
            List<Zutaten> oldZutaten = new ArrayList<>(existingPizza.getZutaten());
            for (Zutaten oldZutat : oldZutaten) {
                oldZutat.setPizzazutaten(null);
            }
            existingPizza.getZutaten().clear();
            pizzaRepository.save(existingPizza); // Speichern nach dem Entfernen der Zutaten
            zutatenRepository.deleteAll(oldZutaten);
            return ResponseEntity.ok().body("Zutaten erfolgreich gelöscht");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Fehler beim Löschen der Zutaten: " + e.getMessage());
        }
    }


}
