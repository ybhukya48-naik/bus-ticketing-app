package com.busticketing.busticketingbackend.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Route")
public class Route {
    @Id
    private Long id;
    private String routeName;
    private String origin;
    private String destination;
    private Double distance;

    public Route() {}

    public Route(Long id, String routeName, String origin, String destination, Double distance) {
        this.id = id;
        this.routeName = routeName;
        this.origin = origin;
        this.destination = destination;
        this.distance = distance;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getRouteName() {
        return routeName;
    }

    public void setRouteName(String routeName) {
        this.routeName = routeName;
    }

    public String getOrigin() {
        return origin;
    }

    public void setOrigin(String origin) {
        this.origin = origin;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public Double getDistance() {
        return distance;
    }

    public void setDistance(Double distance) {
        this.distance = distance;
    }
}
