package edu.hm.cs.example;

import edu.hm.cs.example.Bestellungen.Bestellung;
import edu.hm.cs.example.Bestellungen.BestellungRepository;
import edu.hm.cs.example.Getraenke.Getraenke;
import edu.hm.cs.example.Getraenke.GetraenkeRepository;
import edu.hm.cs.example.Pizza.Pizza;
import edu.hm.cs.example.Pizza.PizzaRepository;
import edu.hm.cs.example.controller.Controller;
import edu.hm.cs.example.zutaten.Zutaten;
import edu.hm.cs.example.zutaten.ZutatenRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

public class ControllerTest {

    @Mock
    private PizzaRepository pizzaRepository;

    @Mock
    private BestellungRepository bestellungRepository;

    @Mock
    private GetraenkeRepository getraenkeRepository;

    @Mock
    private ZutatenRepository zutatenRepository;

    @InjectMocks
    private Controller controller;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    public void testFetchZutatenData() {
        Zutaten zutat1 = new Zutaten();
        zutat1.setPredefined(true);
        Zutaten zutat2 = new Zutaten();
        zutat2.setPredefined(false);
        List<Zutaten> zutaten = new ArrayList<>();
        zutaten.add(zutat1);
        zutaten.add(zutat2);

        when(zutatenRepository.findAll()).thenReturn(zutaten);

        List<Zutaten> result = controller.fetchZutatenData();

        assertEquals(1, result.size());
        assertTrue(result.contains(zutat1));
        assertFalse(result.contains(zutat2));
    }

    @Test
    public void testDeletePizzaByID() {
        Pizza pizza = new Pizza();
        pizza.setId(1L);

        when(pizzaRepository.findById(1L)).thenReturn(Optional.of(pizza));

        ResponseEntity<String> response = controller.deletePizzaByID(1L);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Pizza erfolgreich gelöscht", response.getBody());
        verify(pizzaRepository, times(1)).delete(pizza);
    }

    @Test
    public void testDeletePizzaByID_NotFound() {
        when(pizzaRepository.findById(anyLong())).thenReturn(Optional.empty());

        ResponseEntity<String> response = controller.deletePizzaByID(1L);

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertTrue(response.getBody().contains("Pizza nicht gefunden"));
    }

    @Test
    public void testGetZutatById() {
        Zutaten zutat = new Zutaten();
        zutat.setId(1L);

        when(zutatenRepository.findById(1L)).thenReturn(Optional.of(zutat));

        Zutaten result = controller.getZutatById(1L);

        assertEquals(zutat, result);
    }

    @Test
    public void testGetPizzaById() {
        Pizza pizza = new Pizza();
        pizza.setId(1L);

        when(pizzaRepository.findById(1L)).thenReturn(Optional.of(pizza));

        Pizza result = controller.getPizzaById(1L);

        assertEquals(pizza, result);
    }

    @Test
    public void testAddBestellung() {
        Bestellung bestellung = new Bestellung();
        List<Pizza> pizzas = new ArrayList<>();
        Pizza pizza = new Pizza();
        List<Zutaten> zutaten = new ArrayList<>();
        Zutaten zutat = new Zutaten();
        zutaten.add(zutat);
        pizza.setZutaten(zutaten);
        pizzas.add(pizza);
        bestellung.setPizzas(pizzas);

        List<Getraenke> getraenke = new ArrayList<>();
        Getraenke getraenk = new Getraenke();
        getraenk.setId(1L);
        getraenke.add(getraenk);
        bestellung.setGetraenke(getraenke);

        when(getraenkeRepository.findById(anyLong())).thenReturn(Optional.of(getraenk));
        when(bestellungRepository.save(any(Bestellung.class))).thenReturn(bestellung);

        Bestellung result = controller.addBestellung(bestellung);

        assertNotNull(result);
        verify(bestellungRepository, times(1)).save(any(Bestellung.class));
    }

    @Test
    public void testDeleteBestellungById() {
        Bestellung bestellung = new Bestellung();
        bestellung.setId(1L);

        when(bestellungRepository.findById(1L)).thenReturn(Optional.of(bestellung));

        ResponseEntity<String> response = controller.deleteBestellungById(1L);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Bestellung erfolgreich gelöscht", response.getBody());
        verify(bestellungRepository, times(1)).delete(bestellung);
    }

    @Test
    public void testUpdatePizza() {
        Pizza existingPizza = new Pizza();
        existingPizza.setId(1L);
        existingPizza.setName("Existing Pizza");
        existingPizza.setPreis(10.0);

        Pizza predefinedPizza = new Pizza();
        predefinedPizza.setName("Existing Pizza");
        predefinedPizza.setPreis(10.0);
        predefinedPizza.setPredefined(true);

        when(pizzaRepository.findById(1L)).thenReturn(Optional.of(existingPizza));
        when(pizzaRepository.findAll()).thenReturn(Arrays.asList(predefinedPizza));

        Pizza pizzaDetails = new Pizza();
        pizzaDetails.setName("Updated Pizza");
        pizzaDetails.setBeschreibung("Updated Description");
        pizzaDetails.setImageUrl("updated-image-url");

        Zutaten zutat1 = new Zutaten();
        zutat1.setName("Zutat 1");
        zutat1.setPreis(1.0);

        Zutaten zutat2 = new Zutaten();
        zutat2.setName("Zutat 2");
        zutat2.setPreis(2.0);

        pizzaDetails.setZutaten(Arrays.asList(zutat1, zutat2));

        when(pizzaRepository.save(any(Pizza.class))).thenAnswer(invocation -> invocation.getArgument(0));

        ResponseEntity<Pizza> response = controller.updatePizza(1L, pizzaDetails);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        Pizza updatedPizza = response.getBody();
        assertNotNull(updatedPizza);
        assertEquals("Updated Pizza", updatedPizza.getName());
        assertEquals("Updated Description", updatedPizza.getBeschreibung());
        assertEquals("updated-image-url", updatedPizza.getImageUrl());
        assertEquals(13.0, updatedPizza.getPreis());

        verify(pizzaRepository, times(1)).findById(1L);
        verify(pizzaRepository, times(1)).findAll();
        verify(pizzaRepository, times(1)).save(existingPizza);
    }

    @Test
    public void testFetchPizzaData() {
        Pizza pizza1 = new Pizza();
        pizza1.setName("Pizza 1");
        pizza1.setPredefined(true);

        Pizza pizza2 = new Pizza();
        pizza2.setName("Pizza 2");
        pizza2.setPredefined(false);

        Pizza pizza3 = new Pizza();
        pizza3.setName("Pizza 3");
        pizza3.setPredefined(true);

        List<Pizza> allPizzas = Arrays.asList(pizza1, pizza2, pizza3);

        when(pizzaRepository.findAll()).thenReturn(allPizzas);

        List<Pizza> result = controller.fetchPizzaData();

        assertEquals(2, result.size());
        assertTrue(result.contains(pizza1));
        assertTrue(result.contains(pizza3));
        assertFalse(result.contains(pizza2));

        verify(pizzaRepository, times(1)).findAll();
    }

    @Test
    public void testFetchGetraenkeData() {
        Getraenke getraenk1 = new Getraenke();
        getraenk1.setName("Getränk 1");

        Getraenke getraenk2 = new Getraenke();
        getraenk2.setName("Getränk 2");

        List<Getraenke> allGetraenke = Arrays.asList(getraenk1, getraenk2);

        when(getraenkeRepository.findAll()).thenReturn(allGetraenke);

        List<Getraenke> result = controller.fetchGetraenkeData();

        assertEquals(2, result.size());
        assertTrue(result.contains(getraenk1));
        assertTrue(result.contains(getraenk2));

        verify(getraenkeRepository, times(1)).findAll();
    }

    @Test
    public void testGetGetraenkeById() {
        Getraenke getraenk = new Getraenke();
        getraenk.setId(1L);
        getraenk.setName("Getraenk 1");

        when(getraenkeRepository.findById(1L)).thenReturn(Optional.of(getraenk));

        Getraenke result = controller.getGetraenkeById(1L);

        assertEquals(getraenk, result);

        verify(getraenkeRepository, times(1)).findById(1L);
    }

    @Test
    public void testGetGetraenkeById_NotFound() {
        when(getraenkeRepository.findById(anyLong())).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> controller.getGetraenkeById(1L));

        verify(getraenkeRepository, times(1)).findById(1L);
    }

    @Test
    public void testDeleteGetraenkeByID() {
        Getraenke getraenk = new Getraenke();
        getraenk.setId(1L);

        when(getraenkeRepository.findById(1L)).thenReturn(java.util.Optional.of(getraenk));

        ResponseEntity<String> response = controller.deleteGetraenkeByID(1L);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Getränk erfolgreich von der Bestellung entfernt", response.getBody());

        verify(getraenkeRepository, times(1)).findById(1L);
        verify(getraenkeRepository, times(1)).save(getraenk);
    }

    @Test
    public void testDeleteGetraenkeByID_NotFound() {

        when(getraenkeRepository.findById(anyLong())).thenReturn(java.util.Optional.empty());

        ResponseEntity<String> response = controller.deleteGetraenkeByID(1L);

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertTrue(response.getBody().contains("Getränk nicht gefunden"));

        verify(getraenkeRepository, times(1)).findById(1L);
        verify(getraenkeRepository, never()).save(any());
    }

    @Test
    public void testCreatePizza() {
        List<Zutaten> mockZutaten = new ArrayList<>();
        Zutaten zutat1 = new Zutaten();
        zutat1.setId(1L);
        zutat1.setName("Mozzarella");
        zutat1.setPreis(1.5);
        mockZutaten.add(zutat1);

        Pizza mockPizza = new Pizza();
        mockPizza.setId(1L);
        mockPizza.setName("Margherita");

        when(zutatenRepository.findAll()).thenReturn(mockZutaten);
        when(pizzaRepository.findById(1L)).thenReturn(Optional.of(mockPizza));
        when(pizzaRepository.save(any(Pizza.class))).thenReturn(mockPizza);

        Pizza createdPizza = controller.createPizza();

        assertNotNull(createdPizza);
        assertEquals(mockPizza.getId(), createdPizza.getId());
        assertEquals(mockPizza.getName(), createdPizza.getName());
        assertEquals(mockZutaten.size(), createdPizza.getZutaten().size());
        assertTrue(createdPizza.getZutaten().contains(zutat1));
        verify(pizzaRepository, times(1)).findById(1L);
        verify(pizzaRepository, times(1)).save(any(Pizza.class));
    }

    @Test
    public void testDeleteBestellungById_Success() {

        Bestellung mockBestellung = new Bestellung();
        mockBestellung.setId(1L);

        Pizza mockPizza = new Pizza();
        mockPizza.setId(1L);
        List<Pizza> pizzas = new ArrayList<>();
        pizzas.add(mockPizza);
        mockBestellung.setPizzas(pizzas);

        Getraenke mockGetraenk = new Getraenke();
        mockGetraenk.setId(1L);
        List<Getraenke> getraenke = new ArrayList<>();
        getraenke.add(mockGetraenk);
        mockBestellung.setGetraenke(getraenke);

        when(bestellungRepository.findById(1L)).thenReturn(Optional.of(mockBestellung));

        ResponseEntity<String> response = controller.deleteBestellungById(1L);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Bestellung erfolgreich gelöscht", response.getBody());
        assertTrue(mockBestellung.getPizzas().isEmpty()); // Überprüfen, ob die Pizzas gelöscht wurden
        assertTrue(mockBestellung.getGetraenke().isEmpty()); // Überprüfen, ob die Getränke gelöscht wurden
        verify(bestellungRepository, times(1)).delete(mockBestellung); // Verifizieren, dass die Bestellung gelöscht wurde
    }

    @Test
    public void testDeleteBestellungById_NotFound() {
        when(bestellungRepository.findById(anyLong())).thenReturn(Optional.empty());

        ResponseEntity<String> response = controller.deleteBestellungById(1L);

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertTrue(response.getBody().contains("Bestellung nicht gefunden"));
        verify(bestellungRepository, never()).delete(any(Bestellung.class)); // Verifizieren, dass delete nie aufgerufen wurde
    }

    @Test
    public void testGetBestellungById_Success() {
        Bestellung mockBestellung = new Bestellung();
        mockBestellung.setId(1L);

        when(bestellungRepository.findById(1L)).thenReturn(Optional.of(mockBestellung));

        Bestellung result = controller.getBestellungById(1L);

        assertEquals(mockBestellung, result);
    }

    @Test
    public void testGetBestellungById_NotFound() {
        when(bestellungRepository.findById(anyLong())).thenReturn(Optional.empty());

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            controller.getBestellungById(1L);
        });

        assertEquals("Bestellung nicht gefunden", exception.getMessage());
    }

    @Test
    public void testUpdateBestellung_NotFound() {
        when(bestellungRepository.findById(anyLong())).thenReturn(Optional.empty());

        Bestellung updatedBestellungDetails = new Bestellung();
        updatedBestellungDetails.setId(1L);

        ResponseEntity<Bestellung> response = controller.updateBestellung(1L, updatedBestellungDetails);

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
    }

    @Test
    public void testDeleteZutatenByPizza_Success() {
        Pizza pizza = new Pizza();
        pizza.setId(1L);

        Zutaten zutat1 = new Zutaten();
        zutat1.setId(1L);
        zutat1.setName("Zutat 1");
        Zutaten zutat2 = new Zutaten();
        zutat2.setId(2L);
        zutat2.setName("Zutat 2");

        List<Zutaten> zutatenList = new ArrayList<>();
        zutatenList.add(zutat1);
        zutatenList.add(zutat2);

        pizza.setZutaten(zutatenList);

        when(pizzaRepository.findById(1L)).thenReturn(Optional.of(pizza));
        when(zutatenRepository.findAll()).thenReturn(zutatenList);
        doNothing().when(zutatenRepository).deleteAll(any());

        ResponseEntity<String> response = controller.deleteZutatenByPizza(pizza);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("Zutaten erfolgreich gelöscht", response.getBody());
        assertEquals(pizza.getZutaten().size(), 0);
    }

    @Test
    public void testDeleteZutatenByPizza_PizzaNotFound() {
        Pizza pizza = new Pizza();
        pizza.setId(1L);

        when(pizzaRepository.findById(anyLong())).thenReturn(Optional.empty());

        ResponseEntity<String> response = controller.deleteZutatenByPizza(pizza);

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
    }

    @Test
    public void testFetchBestellungData() {
        Bestellung bestellung1 = new Bestellung();
        bestellung1.setId(1L);
        Bestellung bestellung2 = new Bestellung();
        bestellung2.setId(2L);

        List<Bestellung> bestellungList = new ArrayList<>();
        bestellungList.add(bestellung1);
        bestellungList.add(bestellung2);

        when(bestellungRepository.findAll()).thenReturn(bestellungList);

        List<Bestellung> result = controller.fetchBestellungData();

        assertEquals(2, result.size());
        assertEquals(bestellungList, result);
        verify(bestellungRepository, times(1)).findAll();
    }

}
