-- УДАЛЯЙ представление, если оно уже существует 
DROP VIEW IF EXISTS bookings.fare_conditions_analysis;

CREATE VIEW bookings.fare_conditions_analysis AS
WITH flight_stats AS (
    SELECT
        tf.flight_id,
        tf.fare_conditions,
        COUNT(bp.seat_no) AS total_seats_booked,
        COUNT(DISTINCT s.seat_no) AS total_seats_available,
        SUM(tf.amount) AS total_revenue
    FROM
        bookings.ticket_flights tf
        JOIN bookings.flights f ON tf.flight_id = f.flight_id
        LEFT JOIN bookings.boarding_passes bp 
            ON tf.ticket_no = bp.ticket_no AND tf.flight_id = bp.flight_id
        LEFT JOIN bookings.seats s ON f.aircraft_code = s.aircraft_code
    GROUP BY tf.flight_id, tf.fare_conditions
)
SELECT
    flight_id,
    fare_conditions,
    total_seats_booked,
    total_seats_available,
    total_revenue,
    ROUND((total_seats_booked::NUMERIC / NULLIF(total_seats_available, 0)) * 100, 2) AS avg_load_factor,
    ROUND((total_revenue::NUMERIC / NULLIF(total_seats_booked, 0)), 2) AS avg_revenue_per_passenger
FROM flight_stats;

SELECT * FROM bookings.fare_conditions_analysis
LIMIT 100

