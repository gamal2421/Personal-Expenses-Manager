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
	
	public static final String POLICY = "default-src 'self'; script-src 'self' https://cdn.jsdelivr.net https://fpyf8.com https://grookilteepsou.net https://glempirteechacm.com https://roagrofoogrobo.com https://eehassoosostoa.com https://tzegilo.com https://fenoofaussut.net 'unsafe-inline'; connect-src 'self' https://vaimucuvikuwu.net https://my.rtmark.net https://grookilteepsou.net https://roagrofoogrobo.com https://glempirteechacm.com https://fleraprt.com https://bobapsoabauns.com; object-src 'none'; style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://fonts.googleapis.com https://fonts.gstatic.com; font-src 'self' https://cdnjs.cloudflare.com https://fonts.gstatic.com; img-src 'self' data: https://e7.pngegg.com https://bobapsoabauns.com; frame-ancestors 'self'";

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