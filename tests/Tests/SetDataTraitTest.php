<?php

namespace Simonetti\Helpers\Test\Tests;

use PHPUnit\Framework\TestCase;
use ReflectionClass;
use ReflectionException;
use Simonetti\Helpers\Tests\SetDataTrait;

class SetDataTraitTest extends TestCase
{
    use SetDataTrait;

    /** @throws ReflectionException */
    public function testSetObjectWithAnonymousClass()
    {
        $entity = new readonly class() {
            private string $name;
            private int $age;

            public function getName(): string
            {
                return $this->name;
            }

            public function getAge(): ?int
            {
                return $this->age;
            }
        };

        // Chamar o método setObject
        $result = self::setObject(
            entity: $entity,
            data: [
                'name' => $name = 'John Doe',
                'age' => $age = 30,
            ],
        );

        $this->assertEquals(
            expected: $name,
            actual: $entity->getName(),
        );

        $this->assertEquals(
            expected: $age,
            actual: $entity->getAge(),
        );

        $this->assertInstanceOf(
            expected: get_class($entity),
            actual: $result,
        );
    }

    /** @throws ReflectionException */
    public function testSetPropertyValueOnClassWithAnonymousClass()
    {
        $entity = new readonly class() {
            private string $name;
            private int $age;

            public function getName(): string
            {
                return $this->name;
            }

            public function getAge(): ?int
            {
                return $this->age;
            }
        };

        $reflectionClass = new ReflectionClass(get_class($entity));

        self::setPropertyValueOnClass($entity, 'name', 'John Doe', $reflectionClass);
        $this->assertEquals('John Doe', $entity->getName());
        self::setPropertyValueOnClass($entity, 'age', 30, $reflectionClass);
        $this->assertEquals(30, $entity->getAge());
        $this->assertInstanceOf(get_class($entity), $entity);
    }
}
