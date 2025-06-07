package javawork.personalexp.filters;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class CSPFilter implements Filter {
	
	public static final String POLICY = "default-src 'self'; script-src 'self' https://cdn.jsdelivr.net; object-src 'none'; style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://fonts.googleapis.com; font-src 'self' https://cdnjs.cloudflare.com https://fonts.gstatic.com; img-src 'self' data: https://e7.pngegg.com; frame-ancestors 'self'";

	@Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
    throws IOException, ServletException {
        
    if (response instanceof HttpServletResponse) {
      HttpServletResponse httpResponse = (HttpServletResponse) response;
      httpResponse.setHeader("Content-Security-Policy", CSPFilter.POLICY);
      httpResponse.setHeader("X-Content-Type-Options", "nosniff");
    }
    chain.doFilter(request, response);
  }
    
	@Override
  public void init(FilterConfig filterConfig) throws ServletException { }

	@Override
  public void destroy() { }

}