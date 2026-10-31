package vn.iotstar.websach.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
public class ManagerWebMvcConfig implements WebMvcConfigurer {

    private final ManagerActivityLogInterceptor managerActivityLogInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(managerActivityLogInterceptor)
                .addPathPatterns("/manager/**", "/admin/**");
    }
}
