  # Company-Details-Service        


       Hi Smith, since UAT is not exposed to clients, we focused on CIT, and here is the behavior observed. The sign link works without the Kinde URL. However, I’m forced to use incognito mode; otherwise, the attestation SPA loads directly without redirect — likely due to cache/session from the same browser.

However, after updating the Kinde URL from ausiex-.kinde.com to auth..ausiex.com.au, the flow is working with a single OTP, and the double OTP issue is no longer happening.

We need to decide whether to use both auth and SPA URLs for a single login experience, or use only the SPA URL and rely on automatic redirect to auth when no token is present. However, this has a drawback — the SPA page sometimes loads directly without a token, causing the application info to appear empty.

Also, the cache/session behavior needs further investigation.
      
    
   
         
