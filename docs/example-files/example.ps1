foreach ($i in get-childitem | sort-object length)
{
    $i  #highlight
    $sum += $i.length
}

# 3) variable name token: '$_.length' and 'get-childitem'
:labelA switch -regex -casesensitive (get-childitem | sort length)
{
    "^5" {"length for $_ started with 5" ; continue labelA}
    { $_.length > 20000 } {"length of $_ is greater than 20000"}
    default {"Didn't match anything else..."}
}

class Person
{
    [int]$Age
    Person([int]$a)
    {
        $this.Age = $a
    }
    DoSomething($x)
    {
        $this.DoSomething($x)
    }
}
class Child: Person
{
    [string]$School

    Child([int]$a, [string]$s): base($a)
    {
        $this.School = $s
    }
}
[Child]$littleOne = [Child]::new(10, "Silver Fir Elementary School")
Write-Output "Child's age is $( $littleOne.Age )"