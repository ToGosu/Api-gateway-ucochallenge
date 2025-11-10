package co.edu.uco.apigateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.web.server.SecurityWebFilterChain;

@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {

    @Bean
    public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
        http
            .csrf(ServerHttpSecurity.CsrfSpec::disable)
            .authorizeExchange(exchanges -> exchanges
                // ✅ Rutas públicas (sin autenticación)
                .pathMatchers("/actuator/**").permitAll()
                .pathMatchers("/api/v1/cities/**").permitAll()
                .pathMatchers("/api/v1/idtypes/**").permitAll()
                
                // ✅ Rutas protegidas (requieren JWT)
                .pathMatchers("/api/v1/users/**").authenticated()
                .pathMatchers("/parameters/**").authenticated()
                .pathMatchers("/notifications/**").authenticated()
                
                // ✅ Cualquier otra ruta requiere autenticación
                .anyExchange().authenticated()
            )
            // ✅ Valida JWT con Auth0
            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt.jwkSetUri("https://dev-l7bs34cafn0six34.us.auth0.com/.well-known/jwks.json"))
            );

        return http.build();
    }
}