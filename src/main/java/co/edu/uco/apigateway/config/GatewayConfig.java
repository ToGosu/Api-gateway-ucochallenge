package co.edu.uco.apigateway.config;

import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;

@Configuration
public class GatewayConfig {

    /**
     * Filtro global para logging de requests
     */
    @Bean
    @Order(Ordered.HIGHEST_PRECEDENCE)
    public GlobalFilter loggingFilter() {
        return (exchange, chain) -> {
            var request = exchange.getRequest();
            var startTime = System.currentTimeMillis();
            
            System.out.println("📥 [" + LocalDateTime.now() + "] " +
                request.getMethod() + " " + request.getURI());
            
            return chain.filter(exchange).then(Mono.fromRunnable(() -> {
                var response = exchange.getResponse();
                var duration = System.currentTimeMillis() - startTime;
                
                System.out.println("📤 [" + LocalDateTime.now() + "] " +
                    "Status: " + response.getStatusCode() + 
                    " | Duration: " + duration + "ms");
            }));
        };
    }

    /**
     * Filtro para agregar headers de seguridad
     */
    @Bean
    public GlobalFilter securityHeadersFilter() {
        return (exchange, chain) -> {
            return chain.filter(exchange).then(Mono.fromRunnable(() -> {
                var headers = exchange.getResponse().getHeaders();
                headers.add("X-Content-Type-Options", "nosniff");
                headers.add("X-Frame-Options", "DENY");
                headers.add("X-XSS-Protection", "1; mode=block");
                headers.add("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
            }));
        };
    }
}
