using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace PrintHeaders.Pages
{
    public class IndexModel : PageModel
    {
        public void OnGet()
        {
            //Fetch the headers and print them
            foreach (var h in HttpContext.Request.Headers)
            {

            }
        }
    }
}
