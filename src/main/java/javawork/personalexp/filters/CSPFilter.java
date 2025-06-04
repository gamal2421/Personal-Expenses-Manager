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
	
	public static final String POLICY = "default-src 'self'";

	@Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
    throws IOException, ServletException {
        
    if (response instanceof HttpServletResponse) {
      ((HttpServletResponse)response).setHeader("Content-Security-Policy", CSPFilter.POLICY);
    }
    chain.doFilter(request, response);
  }
    
	@Override
  public void init(FilterConfig filterConfig) throws ServletException { }

	@Override
  public void destroy() { }

} 